# ---------------------------------------------------------------------------------------------------------------------
# RDS PostgreSQL Instance
# ---------------------------------------------------------------------------------------------------------------------

locals {
  final_snapshot_identifier = "${var.final_snapshot_identifier_prefix}-${var.identifier}"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group for ${var.identifier} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.identifier}-sg"
  })
}

resource "aws_security_group_rule" "ingress_cidr" {
  count             = length(var.security_group_ingress_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.security_group_ingress_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_sg" {
  count                    = length(var.security_group_ingress_security_groups)
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.security_group_ingress_security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_db_parameter_group" "this" {
  count = var.parameter_group_name == null && length(var.parameters) > 0 ? 1 : 0

  name        = "${var.identifier}-parameter-group"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.identifier} RDS instance"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = var.parameter_group_name != null ? var.parameter_group_name : (length(var.parameters) > 0 ? aws_db_parameter_group.this[0].name : null)

  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  max_allocated_storage  = var.max_allocated_storage
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately      = var.apply_immediately
  maintenance_window     = var.maintenance_window

  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  deletion_protection     = var.deletion_protection

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}