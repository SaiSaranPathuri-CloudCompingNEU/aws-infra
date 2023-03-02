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
#Rds subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db_subnet_group"
  description = "RDS subnet group for database"
  subnet_ids  = var.private_subnets_ids
  tags = {
    Name = "db_subnet_group"
  }
}
#Rds parameter group
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "dbparametergroup"
  family      = "mysql8.0"
  description = "RDS parameter group for database"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

#Rds instance
resource "aws_db_instance" "db_instance" {
  identifier                = "csye6225"
  engine                    = "mysql"
  engine_version            = "8.0.28"
  instance_class            = "db.t3.micro"
  name                      = var.database_name
  username                  = var.database_username
  password                  = var.database_password
  parameter_group_name      = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids    = [aws_security_group.database.id]
  allocated_storage         = 20
  storage_type              = "gp2"
  multi_az                  = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-snapshot"
  publicly_accessible       = true
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
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



# EC2 security group
resource "aws_security_group" "app_sg" {


  name_prefix = "app_sg_"
  description = "Security group for web application instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application"
  }

}

# EC2 instance
resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  associate_public_ip_address = true
  //create it in public subnet 1 from mynetworking1 module
  subnet_id = var.public_subnets_ids[0]

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  #   accidental termination protection
  disable_api_termination = false
  iam_instance_profile    = aws_iam_instance_profile.app_instance_profile.name

  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }
  #   code for the user data
  user_data = <<EOF

#!/bin/bash
echo "\n" >> /home/ec2-user/.env
echo "DB_USER=${var.database_username} " >> /home/ec2-user/.env
echo "DB_PASSWORD=${var.database_password} " >> /home/ec2-user/.env
echo "DB_HOST=${aws_db_instance.db_instance.endpoint} " >> /home/ec2-user/.env
echo "DB_NAME=${var.database_name} " >> /home/ec2-user/.env
echo "bucketname=${var.bucket_name} " >> /home/ec2-user/.env
echo "S3_REGION=${var.region} " >> /home/ec2-user/.env
sudo chmod +x setenv.sh
sh setenv.sh

 EOF

  tags = {
    Name = "Web App Instance"
  }

}

#attach iam role to ec2 instance
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app_instance_profile"
  role = var.ec2_iam_role
}

output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}