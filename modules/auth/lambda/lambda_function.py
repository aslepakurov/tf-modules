import os
import json
import logging
import psycopg2
from psycopg2 import sql
from urllib.parse import urlparse

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
    """Insert user data into the database."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Using parameterized query to prevent SQL injection
        insert_query = sql.SQL("INSERT INTO users (id, email, is_dev) VALUES (%s, %s, false)")
        cursor.execute(insert_query, (user_id, email))

        conn.commit()
        logger.debug(f"Successfully inserted user {user_id} with email {email}")
        return True
    except Exception as e:
        logger.error(f"Error inserting user data: {str(e)}")
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            cursor.close()
            conn.close()

def lambda_handler(event, context):
    """
    Lambda function handler that processes Cognito post-confirmation events.
    Extracts user ID and email from the event and inserts them into the RDS database.
    """
    logger.info(f"Received event: {json.dumps(event)}")

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
