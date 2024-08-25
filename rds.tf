resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "16.2"
  identifier             = format("%s-db", var.prefix)
  instance_class         = "db.t3.small"
  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_grp.name
  parameter_group_name   = aws_db_parameter_group.pg.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_name                = var.db_name
  username               = var.db_username
  password               = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["db_password"]
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "RDS_subnet_grp" {
  subnet_ids = module.vpc.intra_subnets
}

resource "aws_db_parameter_group" "pg" {
  name   = format("%s-rds-pg", var.prefix)
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

data "aws_secretsmanager_secret" "db" {
  name = "dev/dbKrish"
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

resource "aws_security_group" "rds" {
  name   = format("%s-db-sg", var.prefix)
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.ecs.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}