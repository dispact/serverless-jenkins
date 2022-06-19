output "vpc_id" {
   description = "The VPC ID"
   value = aws_vpc.vpc.id
}

output "public_subnets" {
   description = "List of all the public subnets"
   value = aws_subnet.public_subnet
}

output "private_subnets" {
   description = "List of all the private subnets"
   value = aws_subnet.private_subnet
}