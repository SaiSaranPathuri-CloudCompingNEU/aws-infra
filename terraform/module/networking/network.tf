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
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = "nat"
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

#code to create a nat gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
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