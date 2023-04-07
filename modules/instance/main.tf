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

resource "random_id" "id" {
  byte_length = 4
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
  publicly_accessible       = false
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
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.loadBalancer.id]
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
data "template_file" "user_data" {
  template = <<EOF

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

}
 # Resource to create Ec2 launch template
resource "aws_launch_template" "ec2" {
  name          = "asg_launch_config"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_pair
  user_data     = base64encode(data.template_file.user_data.template)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }
  network_interfaces {
    security_groups             = [aws_security_group.app_sg.id]
    associate_public_ip_address = true
    subnet_id                   = element(var.public_subnets_ids, 1)
  }
  # disable_api_termination = false
  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.name
  }
  tags = {
    "Name" = "Ec2_Tf_${timestamp()}"
  }
}
 
 # EC2 instance
# resource "aws_instance" "app_instance" {
#   ami                         = var.ami_id
#   instance_type               = "t2.micro"
#   key_name                    = var.key_pair
#   associate_public_ip_address = true
#   //create it in public subnet 1 from mynetworking1 module
#   subnet_id = var.public_subnets_ids[0]

#   vpc_security_group_ids = [aws_security_group.app_sg.id]
#   #   accidental termination protection
#   disable_api_termination = false
#   iam_instance_profile    = aws_iam_instance_profile.app_instance_profile.name

#   root_block_device {
#     volume_size           = 50
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }
#   tags = {
#     Name = "Web App Instance"
#   }

# }

#attach iam role to ec2 instance
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "app_instance_profile-${random_id.id.hex}"
  role = var.ec2_iam_role
}

output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}

 # Inserting A record in the route53 hosted Zone
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.name
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}


#load balancer security group
resource "aws_security_group" "loadBalancer" {
  name        = "load balancer"
  description = "Security group for load balancer to access instances"
  vpc_id      = var.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "load balancer"
  }
}



//auto-scaling


# Creating auto scaling group resource
resource "aws_autoscaling_group" "asg" {
  name = "csye6225-asg-spring2023" ##asg_launch_config
  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  default_cooldown    = 60
  vpc_zone_identifier = var.public_subnets_ids ###New Parameter
  ## AvailabilityZones and subnets to know where to create ec2 instances
  enabled_metrics     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]
  metrics_granularity = "1Minute"
  tag {
    key                 = "webapp"
    value               = "webapp_instance"
    propagate_at_launch = true
  }
  target_group_arns = [aws_lb_target_group.alb_tg.arn]
}

# Scaling up and Scaling Down Policies

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  alarm_description   = "Scale Up Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "2"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scale_up.arn}"]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg-ec2-scale-up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "60"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale-down-alarm"
  alarm_description   = "Scale Down Alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "4"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "3"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-ec2-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "60"
}

// load balancer


# Resource to create load balance and attach it to the asg
resource "aws_lb" "lb" {
  name               = "csye6225-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadBalancer.id]
  subnets            = [for subnet in var.public_subnets_ids : subnet]
  tags = {
    Application = "WebApp"
  }
}

# Resource for load balancer to send requests to a target group
resource "aws_lb_target_group" "alb_tg" {
  name        = "csye6225-lb-alb-tg"
  target_type = "instance"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    enabled             = true
    path                = "/healthz"
    port                = 3000
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# Listender resource to listen for load balancer
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

}