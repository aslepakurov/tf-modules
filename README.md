# Terraform Modules

This repository contains a collection of reusable Terraform modules for AWS infrastructure.

## Modules

- [IAM Users](modules/iam/users) - Create and manage IAM users with policies
- [IAM Roles](modules/iam/roles) - Create and manage IAM roles with policies
- [Network](modules/network) - Set up VPC, subnets, and networking components
- [Auth](modules/auth) - Configure Cognito user pools and clients
- [Service](modules/service) - Deploy containerized applications with AWS App Runner
- [Web Static](modules/web-static) - Host static websites with S3 and CloudFront
- [Database](modules/database) - Provision and manage PostgreSQL RDS instances

## Usage

To use a module, include it in your Terraform configuration like this:

### Users

```hcl
module "iam_users" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/users"

  iam_user_name = "example-user"

  policy_files = {
    "example-policy-1" = "path/to/policy1.json"
    "example-policy-2" = "path/to/policy2.json"
  }

  tags = {
    "Environment" = "dev"
    "Project"     = "example-project"
  }
}
```

### Roles 

```hcl
module "iam_roles" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/iam/roles"

  iam_role_name         = "example-role"
  iam_role_description  = "An example IAM role"
  assume_file           = "path/to/assume1.json"
  iam_role_max_session  = 3600

  policy_files = {
    "example-policy-1" = "path/to/policy1.json"
    "example-policy-2" = "path/to/policy2.json"
  }

  tags = {
    "Environment" = "dev"
    "Project"     = "example-project"
  }
}
```

### Network

```hcl
module "network" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/network"

  aws_region   = "us-west-2"
  aws_project  = "example-project"
  vpc_cidr     = "10.0.0.0/16"
  az_count     = 2

  # Optional parameters with defaults
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true  # Set to false for dev environments to save costs
  single_nat_gateway   = true  # Set to false for production for high availability

  tags = {
    "Environment" = "dev"
    "Project"     = "example-project"
  }
}
```

### Auth (Cognito)

```hcl
module "auth" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/auth"

  project_name = "example-project"

  app_clients = [
    {
      name = "web-client"
      generate_secret = false
      callback_urls = ["https://example.com/callback"]
      logout_urls = ["https://example.com/logout"]
      # OAuth configuration
      allowed_oauth_flows = ["code", "implicit"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes = ["openid", "email", "profile"]
      supported_identity_providers = ["COGNITO"]
    },
    {
      name = "mobile-client"
      generate_secret = true
      # OAuth configuration
      allowed_oauth_flows = ["code"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes = ["openid", "email"]
    }
  ]

  password_policy = {
    minimum_length = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers = true
    require_symbols = true
  }
}
```

### Service (App Runner)

```hcl
module "service" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/service"

  service_name = "example-service"
  service_image_name = "123456789012.dkr.ecr.us-west-2.amazonaws.com/example-service"
  service_image_version = "latest"
  service_custom_domain = "api.example.com"
  service_port = 8080

  instance_iam_arn = "arn:aws:iam::123456789012:role/AppRunnerInstanceRole"
  access_iam_arn = "arn:aws:iam::123456789012:role/AppRunnerAccessRole"

  env = {
    "NODE_ENV" = "production"
    "LOG_LEVEL" = "info"
  }

  secret_env = {
    "DATABASE_URL" = "arn:aws:secretsmanager:us-west-2:123456789012:secret:database-url"
  }

  min_workers = 1
  max_workers = 5

  tags = {
    "Environment" = "production"
    "Project"     = "example-project"
  }
}
```

### Web Static (S3 + CloudFront)

```hcl
module "web_static" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/web-static"

  # Add example configuration for web-static module
  # (Parameters will depend on the actual implementation)
}
```

### Database (PostgreSQL RDS)

```hcl
module "database" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/database"

  identifier = "example-postgres"
  engine_version = "14.6"
  instance_class = "db.t3.small"

  allocated_storage = 20
  max_allocated_storage = 100

  username = "dbadmin"
  password = var.db_password # Use a variable or AWS Secrets Manager

  # Use outputs from the network module
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  # Allow access from the service security group
  security_group_ingress_security_groups = [module.service.security_group_id]

  # High availability and backup settings
  multi_az = true
  backup_retention_period = 7
  deletion_protection = true

  # Performance monitoring
  monitoring_interval = 60
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  db_name = "application"

  tags = {
    "Environment" = "production"
    "Project"     = "example-project"
  }
}

# Example of how to use the database outputs
output "database_endpoint" {
  description = "The database connection endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_name" {
  description = "The database name"
  value       = module.database.db_instance_name
}
```

## Module Dependencies

Some modules work well together:

- The **Network** module creates the VPC and subnets that the **Database** module can use
- The **Database** module can provide connection information to the **Service** module
- The **Auth** module can be used to secure the applications deployed with the **Service** module
- The **Web Static** module can host the frontend that communicates with backends deployed using the **Service** module

## Contributing

To contribute to this repository:

1. Create a new branch for your changes
2. Make your changes and test them
3. Submit a pull request with a clear description of your changes
