# App with Database Example

This example demonstrates how to use the network, database, and app modules together to create a secure architecture where:

1. The app and database are in the same VPC
2. The database is in a private subnet and not accessible from the public internet
3. The app can access the database through the VPC
4. The database connection URL is passed to the app as an environment variable

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                             VPC                                 │
│                                                                 │
│  ┌─────────────────┐                    ┌───────────────────┐   │
│  │                 │                    │                   │   │
│  │  App Service    │                    │  Database         │   │
│  │  (AppRunner)    │◄───────────────────┤  (RDS)           │   │
│  │                 │    Private Network │                   │   │
│  └─────────────────┘                    └───────────────────┘   │
│         ▲                                                       │
│         │                                                       │
└─────────┼───────────────────────────────────────────────────────┘
          │
          │ Public Access
          │
┌─────────▼───────────┐
│                     │
│  Internet           │
│                     │
└─────────────────────┘
```

## Security Features

1. **Private Database**: The database is deployed in private subnets and has `publicly_accessible = false`
2. **Security Group Rules**: The database security group only allows ingress from the app's security group
3. **No Public CIDR Access**: The database has no ingress rules from public CIDR blocks

## Usage

To use this example, you need to provide values for the required variables:

```hcl
module "app_with_database" {
  source = "path/to/examples/app_with_database"

  # Required variables
  db_password        = "your-secure-password"
  app_image_name     = "your-app-image"
  app_custom_domain  = "your-app-domain.com"
  app_instance_iam_arn = "arn:aws:iam::123456789012:role/app-instance-role"
  app_access_iam_arn   = "arn:aws:iam::123456789012:role/app-access-role"

  # Optional variables with defaults
  aws_region         = "us-west-2"
  project_name       = "example"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 2
  db_name            = "exampledb"
  db_username        = "dbadmin"
  app_image_version  = "latest"
  
  tags = {
    Environment = "example"
    Terraform   = "true"
  }
}
```

## Outputs

- `app_url`: The URL of the deployed app
- `database_endpoint`: The endpoint of the database

## Notes

- The database has `prevent_destroy = true` to protect against accidental deletion
- The app uses a VPC connector to access resources in the VPC
- The database connection URL is passed to the app as the `DATABASE_URL` environment variable