
resource "random_id" "id" {
  byte_length = 4
}

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${random_id.id.hex}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index % length(var.availability_zones)) //this line will distribute the subnets across the availability zones
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${random_id.id.hex}"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  count             = length(var.private_subnets_cidr)
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
  tags = {
    Name = "private-subnet-${random_id.id.hex}"
  }
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "igw-${random_id.id.hex}"
  }
}


/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "private-route-table-${random_id.id.hex}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "public-route-table-${random_id.id.hex}"
  }
}

# Route for internet in public subnet
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw1.id

}


/* Associate public subnet with public route table */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id

}

/* Associate private subnet with private route table */
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id

}

output "vpc_id" {
  value = aws_vpc.vpc1.id
}
output "public_subnets_ids" {
  value = aws_subnet.public_subnet.*.id
}
output "private_subnets_ids" {
  value = aws_subnet.private_subnet.*.id
}
