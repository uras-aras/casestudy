data "aws_availability_zones" "available" {
    state = "available"
}

# Main VPC
resource "aws_vpc" "levelup_vpc" {
    cidr_block = var.LEVELUP_VPC_CIDR_BLOC
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags = {
        Name = "${var.ENVIRONMENT}-vpc"
    }
}

# Public Subnets

# Public Subnet 1
resource "aws_subnet" "levelup_vpc_public_subnet_1" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_VPC_PUBLIC_SUBNET1_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-public-subnet-1"
    }
}

# Public Subnet 2
resource "aws_subnet" "levelup_vpc_public_subnet_2" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_VPC_PUBLIC_SUBNET2_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-public-subnet-2"
    }
}

# Private Subnet 1
resource "aws_subnet" "levelup_vpc_private_subnet_1" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_VPC_PRIVATE_SUBNET1_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-private-subnet-1"
    }
}

# Private Subnet 2
resource "aws_subnet" "levelup_vpc_private_subnet_2" {
    vpc_id = aws_vpc.levelup_vpc.id
    cidr_block = var.LEVELUP_VPC_PRIVATE_SUBNET2_CIDR_BLOCK
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-private-subnet-2"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "levelup_igw" {
    vpc_id = aws_vpc.levelup_vpc.id

    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-internet-gateway"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "levelup_nat_eip" {
    vpc = true
    depends_on = [aws_internet_gateway.levelup_igw]
}

# NAT Gateway for Private IP Address
resource "aws_nat_gateway" "levelup_ngw" {
    allocation_id = aws_eip.levelup_nat_eip.id
    subnet_id = aws_subnet.levelup_vpc_public_subnet_1.id
    depends_on = [aws_internet_gateway.levelup_igw]
    tags = {
        Name = "${var.ENVIRONMENT}-levelup-vpc-NAT-gateway"
    }
}

# Route Table for Public Architecture
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.levelup_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.levelup_igw.id
    }

    tags = {
      Name = "${var.ENVIRONMENT}-levelup-public-route-table"
    }
}

# Route Table for Private Architecture
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.levelup_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.levelup_ngw.id
    }

    tags = {
      Name = "${var.ENVIRONMENT}-levelup-private-route-table"
    }
}

# Route Table Association with Public Subnets
resource "aws_route_table_association" "to_public_subnet1" {
    subnet_id = aws_subnet.levelup_vpc_public_subnet_1.id
    route_table_id = aws_route_table.public.id 
}

resource "aws_route_table_association" "to_public_subnet2" {
    subnet_id = aws_subnet.levelup_vpc_public_subnet_2.id
    route_table_id = aws_route_table.public.id 
}

# Route Table Association with Private Subnets
resource "aws_route_table_association" "to_private_subnet1" {
    subnet_id = aws_subnet.levelup_vpc_private_subnet_1.id
    route_table_id = aws_route_table.private.id 
}

resource "aws_route_table_association" "to_private_subnet2" {
    subnet_id = aws_subnet.levelup_vpc_public_subnet_2.id
    route_table_id = aws_route_table.public.id 
}

provider "aws" {
    region = var.AWS_REGION
}

# Output Specific to Custom VPC
output "my_vpc_id" {
    value = aws_vpc.levelup_vpc.id 
    description = "VPC ID"
}

output "private_subnet1_id" {
    value = aws_subnet.levelup_vpc_private_subnet_1.id 
    description = "Subnet ID"
}

output "private_subnet2_id" {
    value = aws_subnet.levelup_vpc_private_subnet_2.id 
    description = "Subnet ID"
}

output "public_subnet1_id" {
    value = aws_subnet.levelup_vpc_public_subnet_1.id 
    description = "Subnet ID"
}

output "public_subnet2_id" {
    value = aws_subnet.levelup_vpc_public_subnet_2.id 
    description = "Subnet ID"
}