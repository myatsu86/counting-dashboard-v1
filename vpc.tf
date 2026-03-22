# VPC and Networking Resources for Counting Dashboard
resource "aws_vpc" "counting-dashboard-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name        = "${var.prefix}-vpc-${var.region}"
    environment = "${var.environment}"
  }
}
# Public Subnet for Dashboard application (frontend)
resource "aws_subnet" "dashboard-subnet" {
  vpc_id     = aws_vpc.counting-dashboard-vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    name = "${var.prefix}-public-subnet"
  }
}
# Private Subnet for Counting application (Backend)
resource "aws_subnet" "counting-subnet" {
  vpc_id     = aws_vpc.counting-dashboard-vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    name = "${var.prefix}-private-subnet"
  }
}
# Security Group for Dashboard (frontend) allowing HTTP, SSH from my IP range and 8000 for application access
# Egress allows all outbound traffic to the internet for updates and external API calls
resource "aws_security_group" "sg-dashboard" {
  name = "dashboard-security-group"

  vpc_id = aws_vpc.counting-dashboard-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "dashboard-security-group"
  }
}
# Security Group for Counting application (backend) SSH and 9000 for application access ONLY from frontend subnet
# Egress allows all outbound traffic to the internet for updates and external API calls
resource "aws_security_group" "sg-counting" {
  name = "counting-security-group"

  vpc_id = aws_vpc.counting-dashboard-vpc.id

  ingress {
    description = "Allow SSH from public subnet or bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  ingress {
    description     = "Allow dashboard app to access counting app"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-dashboard.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "dashboard-security-group"
  }
}
# Internet Gateway for VPC to allow outbound internet access for public subnet and NAT Gateway
resource "aws_internet_gateway" "counting-dashboard-igw" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.dashboard-subnet.id

  tags = {
    Name = "${var.prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.counting-dashboard-igw]
}

# Public route table default route to Internet Gateway
resource "aws_route_table" "counting-dashboard-rt" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.counting-dashboard-igw.id
  }
}
# Associate public subnet with public route table
resource "aws_route_table_association" "counting-dashboard" {
  subnet_id      = aws_subnet.dashboard-subnet.id
  route_table_id = aws_route_table.counting-dashboard-rt.id
}

# Private route table default route to NAT Gateway
resource "aws_route_table" "counting-private-rt" {
  vpc_id = aws_vpc.counting-dashboard-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}
# Associate private subnet with private route table
resource "aws_route_table_association" "counting_dashboard_private_assoc" {
  subnet_id      = aws_subnet.counting-subnet.id
  route_table_id = aws_route_table.counting-private-rt.id
}
