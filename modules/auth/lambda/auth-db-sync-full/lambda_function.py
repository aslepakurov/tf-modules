"""
Lambda function for syncing Cognito users to a PostgreSQL database.

This function can be triggered in three ways:
1. As a Cognito post-confirmation trigger - processes a single user when they sign up
2. As a scheduled event from EventBridge - performs a full sync of all users
3. Manually with a specific action parameter - performs a full sync on demand

To trigger a full sync manually, invoke the Lambda with the following event:
{
    "action": "sync_users"
}

Environment variables required:
- RDS_URL: PostgreSQL connection URL (e.g., postgresql://hostname:5432)
- RDS_DB_NAME: Database name
- RDS_USERNAME: Database username
- RDS_PASSWORD: Database password
- USER_POOL_ID: Cognito user pool ID
"""

import os
import json
import logging
import psycopg2
from psycopg2 import sql
from urllib.parse import urlparse
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_db_connection():
    """Create a connection to the PostgreSQL database."""
    try:
        # Parse the RDS_URL to extract schema, host, and port
        url = urlparse(os.environ['RDS_URL'])

        # Extract host and port from the URL
        host = url.hostname
        port = url.port

        conn = psycopg2.connect(
            host=host,
            database=os.environ['RDS_DB_NAME'],
            user=os.environ['RDS_USERNAME'],
            password=os.environ['RDS_PASSWORD'],
            port=port
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection error: {str(e)}")
        raise e

def insert_user(user_id, email):
    """Insert user data into the database. If the user already exists, update their email."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Using parameterized query with ON CONFLICT to handle duplicate users
        upsert_query = sql.SQL("""
            INSERT INTO users (id, email, is_dev) 
            VALUES (%s, %s, false)
            ON CONFLICT (id) 
            DO UPDATE SET email = EXCLUDED.email
        """)
        cursor.execute(upsert_query, (user_id, email))

        conn.commit()
        logger.debug(f"Successfully upserted user {user_id} with email {email}")
        return True
    except Exception as e:
        logger.error(f"Error upserting user data: {str(e)}")
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            cursor.close()
            conn.close()

def sync_all_users_from_cognito():
    """
    List all users in the Cognito user pool and insert them into the database.
    Handles errors gracefully and continues processing even if there are issues with individual users.
    """
    try:
        # Get the user pool ID from environment variables
        user_pool_id = os.environ.get('USER_POOL_ID')
        if not user_pool_id:
            logger.error("USER_POOL_ID environment variable not set")
            return False

        # Create a Cognito client
        cognito_client = boto3.client('cognito-idp')

        # Initialize counters
        success_count = 0
        error_count = 0
        skipped_count = 0
        total_users = 0

        try:
            # List users in the user pool with pagination
            paginator = cognito_client.get_paginator('list_users')
            page_iterator = paginator.paginate(
                UserPoolId=user_pool_id
            )

            # Process each page of users
            for page in page_iterator:
                users = page.get('Users', [])
                total_users += len(users)

                for user in users:
                    try:
                        # Extract user ID
                        user_id = user.get('Username')
                        if not user_id:
                            logger.warning("User without Username found, skipping")
                            skipped_count += 1
                            continue

                        # Extract email from user attributes
                        email = None
                        for attr in user.get('Attributes', []):
                            if attr.get('Name') == 'email':
                                email = attr.get('Value')
                                break

                        if not email:
                            logger.warning(f"Email not found for user {user_id}, skipping")
                            skipped_count += 1
                            continue

                        # Insert or update user data in the database
                        insert_user(user_id, email)
                        success_count += 1
                        logger.info(f"Processed user {user_id} with email {email}")

                    except Exception as e:
                        logger.error(f"Error processing user {user_id if 'user_id' in locals() else 'unknown'}: {str(e)}")
                        error_count += 1
                        # Continue with next user

        except Exception as e:
            logger.error(f"Error during user pagination: {str(e)}")
            # Continue with summary

        # Log summary
        logger.info(f"Sync summary: Total users: {total_users}, Successful: {success_count}, Errors: {error_count}, Skipped: {skipped_count}")

        # Return success if we processed at least some users successfully
        return success_count > 0

    except Exception as e:
        logger.error(f"Critical error syncing users from Cognito: {str(e)}")
        return False

def lambda_handler(event, context):
    """
    Lambda function handler that processes Cognito post-confirmation events
    or performs a full sync of all users from Cognito to the database.

    The function can be triggered in three ways:
    1. As a Cognito post-confirmation trigger (processes a single user)
    2. As a scheduled event from EventBridge (performs a full sync)
    3. Manually with a specific action parameter (performs a full sync)
    """
    logger.info(f"Received event: {json.dumps(event)}")

    # Check if this is a scheduled event for full sync
    if 'source' in event and event['source'] == 'aws.events':
        logger.info("Processing scheduled event for full user sync")
        success = sync_all_users_from_cognito()
        return {
            'statusCode': 200 if success else 500,
            'body': json.dumps('Full user sync completed successfully' if success else 'Full user sync completed with errors')
        }

    # Check if this is a manual trigger with action parameter
    if isinstance(event, dict) and event.get('action') == 'sync_users':
        logger.info("Processing manual trigger for full user sync")
        success = sync_all_users_from_cognito()
        return {
            'statusCode': 200 if success else 500,
            'body': json.dumps('Full user sync completed successfully' if success else 'Full user sync completed with errors')
        }

    # Otherwise, process as a Cognito post-confirmation event
    try:
        # Extract user attributes from the Cognito event
        user_id = event['userName']
        user_attributes = event['request']['userAttributes']
        email = user_attributes.get('email')

        if not email:
            logger.error("Email not found in user attributes")
            return event

        # Insert user data into the database
        insert_user(user_id, email)

        logger.info(f"Successfully processed user {user_id}")
        return event
    except Exception as e:
        logger.error(f"Error processing Cognito event: {str(e)}")
        # Return the event to allow the Cognito flow to continue even if there's an error
        # This prevents blocking user registration if the database operation fails
        return event
