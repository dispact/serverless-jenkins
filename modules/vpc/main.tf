# Variables that are being passed in
variable "prefix" {}
variable "vpc_cidr_block" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "public_subnet_blocks" {}
variable "private_subnet_blocks" {}
variable "region" {}
variable "vpc_endpoints_sg" {}

# Grabbing the available AZs in our region
data "aws_availability_zones" "available" {
   state = "available"
}

# Creating the VPC with the vpc_cidr_block variable
# and enabling dns hostnames and support
resource "aws_vpc" "vpc" {
   cidr_block           = var.vpc_cidr_block
   enable_dns_hostnames = true
   enable_dns_support   = true

   tags = {
      Name = "${var.prefix}-vpc"
   }
}

# Creating an internet gateway inside the VPC
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc.id

   tags = {
      Name = "${var.prefix}-igw"
   }
}

# Creating X number of public subnets based on the number
# specified in the public_subnets variable
resource "aws_subnet" "public_subnet" {
   count             = var.public_subnets
   vpc_id            = aws_vpc.vpc.id
   cidr_block        = var.public_subnet_blocks[count.index]
   availability_zone = data.aws_availability_zones.available.names[count.index]

   # Tags will be formatted like: PREFIX-public-subnet-01, PREFIX-public-subnet-02
   tags = {
      Name = "${format("${var.prefix}-public-subnet-%02d", count.index + 1)}"
   }
}

# Creating X number of private subnets based on the number
# specified in the private_subnets variable
resource "aws_subnet" "private_subnet" {
   count             = var.private_subnets
   vpc_id            = aws_vpc.vpc.id
   cidr_block        = var.private_subnet_blocks[count.index]
   availability_zone = data.aws_availability_zones.available.names[count.index]

   # Tags will be formatted like: PREFIX-private-subnet-01, PREFIX-private-subnet-02
   tags = {
      Name = "${format("${var.prefix}-private-subnet-%02d", count.index + 1)}"
   }
}

# Creating public route table and adding the 
# internet gateway as a route
resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.vpc.id

   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
   }

   tags = {
      Name = "${var.prefix}-public-rt"
   }
}

# Associating the public route table with all the public subnets
resource "aws_route_table_association" "public" {
   count          = var.public_subnets
   route_table_id = aws_route_table.public_rt.id
   subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Creating an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
   vpc = true   

   tags = {
      Name = "${var.prefix}-eip"
   }
}

# Creating a NAT gateway and putting it inside the first subnet
# and assigning the Elastic IP to it
resource "aws_nat_gateway" "nat_gateway" {
   allocation_id  = aws_eip.nat_gateway_eip.id
   subnet_id      = aws_subnet.private_subnet[0].id

   tags = {
      Name = "${var.prefix}-nat-gateway"
   }
}

# Creating a private route table and adding the 
# NAT gateway as a route
resource "aws_route_table" "private_rt" {
   vpc_id = aws_vpc.vpc.id

   route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway.id
   }

   tags = {
      Name = "${var.prefix}-private-rt"
   }
}

# Associating the private route table with all the private subnets
resource "aws_route_table_association" "private" {
   count          = var.private_subnets
   route_table_id = aws_route_table.private_rt.id
   subnet_id      = aws_subnet.private_subnet[count.index].id
}

# Creating a region specific S3 gateway VPC endpoint
resource "aws_vpc_endpoint" "s3" {
   vpc_id            = aws_vpc.vpc.id
   service_name      = "com.amazonaws.${var.region}.s3"
   vpc_endpoint_type = "Gateway"

   tags = {
      Name = "${var.prefix}-s3-endpoint"
   }
}

# Adding the S3 endpoint to the private route table
resource "aws_vpc_endpoint_route_table_association" "s3_endpoint" {
   route_table_id    = aws_route_table.private_rt.id
   vpc_endpoint_id   = aws_vpc_endpoint.s3.id
}

# List of all the interface-type VPC endpoints that we will need
locals {
   endpoints = [
      "com.amazonaws.${var.region}.sts",
      "com.amazonaws.${var.region}.ecr.api",
      "com.amazonaws.${var.region}.ecr.dkr",
      "com.amazonaws.${var.region}.logs",
      "com.amazonaws.${var.region}.ecs"
   ]
}

# Here we are creating VPC endpoints based on the
# list of endpoints specified above. Each endpoint is put in
# all the private subnets and gets the VPC Endpoint security group
# attached to it
resource "aws_vpc_endpoint" "endpoint" {
   count          = length(local.endpoints)
   vpc_id         = aws_vpc.vpc.id
   service_name   = local.endpoints[count.index]

   subnet_ids           = [for subnet in aws_subnet.private_subnet : subnet.id]
   security_group_ids   = [var.vpc_endpoints_sg]
   private_dns_enabled  = true
   vpc_endpoint_type    = "Interface"

   # This is going to tag all endpoints based on what they are,
   # for example: PREFIX-sts-endpoint, PREFIX-ecs-endpoint
   tags = {
      Name = "${var.prefix}-${
         try(
            replace(split(local.endpoints[count.index], "${var.region}.")[1]), ".", "-",
            split(local.endpoints[count.index], ".")[3]
         )
      }-endpoint"
   }
}