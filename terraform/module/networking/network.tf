#code to fetch all the availability zones in the region we are operating in
#data "aws_availability_zones" "available" {}

#code to create a vpc
resource "aws_vpc" "my_vpc" {

  cidr_block = var.cidr
  tags = {
    Name = "my_vpc"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "igw"
  }
}

#code to create a public subnet
resource "aws_subnet" "public_subnet" {

  vpc_id = aws_vpc.my_vpc.id        #specifying to which vpc this public subnet belongs to
  count  = length(var.public_cidrs) #get the count of number of public subnet cidrs you gave
  #az_count = "${length(data.aws_availability_zones.available.names)}" #get the count of number of availability zones present in the region you are operating in

  cidr_block              = var.public_cidrs[count.index]                                                  #setting the cidr_block for this public subnet dynamically
  availability_zone       = var.aws_availability_zones[count.index % (length(var.aws_availability_zones))] #setting the availability_zone for this public subnet dynamically
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet - ${var.public_cidrs[count.index]} - ${var.aws_availability_zones[count.index % (length(var.aws_availability_zones))]}"
  }
}

#code to create a private subnet
resource "aws_subnet" "private_subnet" {

  vpc_id = aws_vpc.my_vpc.id         #specifying to which vpc this private subnet belongs to
  count  = length(var.private_cidrs) #get the count of number of private subnet cidrs you gave
  #az_count = "${length(data.aws_availability_zones.available.names)}" #get the count of number of availability zones present in the region you are operating in

  cidr_block              = var.private_cidrs[count.index]                                                 #setting the cidr_block for this private subnet dynamically
  availability_zone       = var.aws_availability_zones[count.index % (length(var.aws_availability_zones))] #setting the availability_zone for this private subnet dynamically
  map_public_ip_on_launch = true
  tags = {
    Name = "private_subnet - ${var.private_cidrs[count.index]} - ${var.aws_availability_zones[count.index % (length(var.aws_availability_zones))]}"
  }
}

#code to create a route table for public subnet
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

#code to create a route table for public subnet
resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "private_route_table"
  }
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}


#code to create subnet route table association for public subnet
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidrs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidrs)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "sg" {
  name_prefix = "app-"
  vpc_id      = aws_vpc.my_vpc.id
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
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.ssh_key
}

resource "aws_instance" "example" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = element(aws_subnet.public_subnet.*.id, 0)
  key_name               = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  disable_api_termination = true
  tags = {
    "Name" = "My_Ec2_${timestamp()}"
  }
}

