# Main VPC that contains all subnets and network resources.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Public subnets are used for resources that need direct internet access.
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = true
}

# Private subnets are used for internal resources such as applications and databases.
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private1_cidr
  availability_zone = var.availability_zone1
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private2_cidr
  availability_zone = var.availability_zone2
}

# Internet Gateway allows public subnets to reach the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Elastic IP used by the NAT Gateway.
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway lets private subnets reach the internet without being public.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  depends_on = [aws_internet_gateway.main]
}

# Public route table sends internet traffic to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate both public subnets with the public route table.
resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public2.id
}

# Private route table sends internet traffic through the NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Associate both private subnets with the private route table.
resource "aws_route_table_association" "private1" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private1.id
}

resource "aws_route_table_association" "private2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private2.id
}
