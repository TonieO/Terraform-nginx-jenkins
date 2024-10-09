# 1. Create a VPC
resource "aws_vpc" "group10_nginx_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "devops-group-10"
  }
}

# 2. Create a public Subnet
resource "aws_subnet" "group10_public_subnet" {
  vpc_id     = aws_vpc.group10_nginx_vpc.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "devops-group-10"
  }
}

# 3. Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "group10_igw" {
  vpc_id = aws_vpc.group10_nginx_vpc.id

  tags = {
    Name = "devops-group-10"
  }
}

# 4. Create a Route Table for the Public Subnet
resource "aws_route_table" "group10_routetable" {
  vpc_id = aws_vpc.group10_nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.group10_igw.id
  }
  
  tags = {
    Name = "devops-group-10"
  }
}

# 5. Associate Route Table with the public Subnet
resource "aws_route_table_association" "group10_public_rt_assoc" {
  subnet_id      = aws_subnet.group10_public_subnet.id
  route_table_id = aws_route_table.group10_routetable.id
}

# 6. Create a Security Group to allow SSH and HTTP access
resource "aws_security_group" "group10_ec2_sg" {
  vpc_id = aws_vpc.group10_nginx_vpc.id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-group-10"
  }
}

# 7. Launch an EC2 Instance
resource "aws_instance" "group10_nginx_server" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.group10_public_subnet.id
  security_groups = [aws_security_group.group10_ec2_sg.id]
  
  # User Data Script to install NGINX
  # Update package list and install nginx
user_data = <<-EOF
    #!/bin/bash
  sudo apt update -y &&
  sudo apt install -y nginx

  #Write demo HTML to the NGINX Root Directory
  echo "Hello NGINX Demo" > /var/www/html/index.html
EOF
}