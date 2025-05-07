# Database Module

This module provisions a PostgreSQL RDS instance with sensible defaults and security configurations.

## Cost Considerations

To avoid unexpected costs, consider the following:

1. **Instance Type**: Default is `db.t3.micro`, which is suitable for development/testing. For production, consider `db.t3.small` or larger.
2. **Storage Auto-scaling**: Default max storage is 50GB. Set a reasonable limit based on expected growth or set to 0 to disable auto-scaling.
3. **Multi-AZ Deployment**: Disabled by default. Enabling this doubles the cost but provides high availability. Recommended for production environments.
4. **Performance Insights**: Disabled by default. Enabling incurs additional costs but provides valuable monitoring capabilities.
5. **Backup Retention**: Default is 7 days. Longer retention periods increase storage costs.
6. **Enhanced Monitoring**: Disabled by default (monitoring_interval = 0). Enabling incurs additional costs.

## Integration with Other Modules

### Network Module

This module requires subnet IDs and a VPC ID from the network module:

```hcl
module "database" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/database"
  
  # ... other configuration ...
  
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets
}
```

### Service Module

The service module can use the database connection information as environment variables:

```hcl
module "service" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/service"
  
  # ... other configuration ...
  
  env = {
    "DB_HOST" = module.database.db_instance_endpoint
    "DB_PORT" = module.database.db_instance_port
    "DB_NAME" = module.database.db_instance_name
  }
  
  # For sensitive information, use secret_env
  secret_env = {
    "DB_USERNAME" = "arn:aws:secretsmanager:region:account-id:secret:db-username"
    "DB_PASSWORD" = "arn:aws:secretsmanager:region:account-id:secret:db-password"
  }
}
```

## Security Best Practices

1. **Private Subnets**: Deploy the database in private subnets to prevent direct internet access.
2. **Security Groups**: Use the `security_group_ingress_security_groups` parameter to allow access only from specific security groups.
3. **Encryption**: Storage encryption is enabled by default.
4. **Deletion Protection**: Enabled by default to prevent accidental deletion.
5. **Password Management**: Use AWS Secrets Manager or similar service to manage database credentials.

## Example Usage

```hcl
module "database" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/database"

  identifier = "example-postgres"
  engine_version = "14.6"
  instance_class = "db.t3.small"

  allocated_storage = 20
  max_allocated_storage = 50

  username = "dbadmin"
  password = var.db_password # Use a variable or AWS Secrets Manager

  # Use outputs from the network module
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  # Allow access from the service security group
  security_group_ingress_security_groups = [module.service.security_group_id]

  # High availability and backup settings
  multi_az = true # Enable for production, doubles cost
  backup_retention_period = 7
  deletion_protection = true

  # Performance monitoring - enable for production
  monitoring_interval = 60
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  db_name = "application"

  tags = {
    "Environment" = "production"
    "Project"     = "example-project"
  }
}
```