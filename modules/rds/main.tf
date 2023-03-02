#database security group
resource "aws_security_group" "database" {
  name        = "database"
  description = "Security group for RDS instance for database"
  vpc_id      = var.vpc_id
  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    "Name" = "database-sg"
  }
}

#Rds parameter group
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "db_parameter_group"
  family      = "mysql8.0"
  description = "RDS parameter group for database"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

#Rds instance
resource "aws_db_instance" "db_instance" {
  identifier           = "csye6225"
  engine               = "mysql"
  engine_version       = "8.0.19"
  instance_class       = "db.t3.micro"
  name                 = var.database_name
  username             = var.database_username
  password             = var.database_password
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name
  security_group_ids   = [aws_security_group.database.id]
  allocated_storage    = 20
  storage_type         = "gp2"
  multi_az             = false
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  tags = {
    Name = "db_instance"
  }
}

#output database name
output "database_name" {
  value = aws_db_instance.db_instance.name
}
#output database username
output "database_username" {
  value = aws_db_instance.db_instance.username
}
#output database password
output "database_password" {
  value = aws_db_instance.db_instance.password
}
#output database endpoint
output "database_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}



