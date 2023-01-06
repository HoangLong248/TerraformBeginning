# Configure the AWS Provider
provider "aws" {
    profile = "myprofile"
    region = "us-east-1"
}

# VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Production"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "prod-gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "Production"
  }
}

# Route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-gw.id
  }

  tags = {
    Name = "Production"
  }
}

# Subnet
resource "aws_subnet" "prod-subnet1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Production"
  }
}

# Associate with route table
resource "aws_route_table_association" "prod-route-table-associate" {
  subnet_id      = aws_subnet.prod-subnet1.id
  route_table_id = aws_route_table.prod-route-table.id
}



# Security Group
resource "aws_security_group" "allow-web-ssh" {
  name        = "allow-web-ssh"
  description = "Allow Web, SSH traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow Web, SSH Traffic"
  }
}

# Network Interfact
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.prod-subnet1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web-ssh.id]

}


# Elastic IP, deployment elastic Ip need internet gw first
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.prod-gw
  ]
}

# Ubuntu Server with install apache/apache2
resource "aws_instance" "web-server-instance" {
  ami             = "ami-0b93ce03dcbcb10f6" 
  instance_type   = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main2-key"

  network_interface {
    network_interface_id = aws_network_interface.web-server-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "*** Installing apache2"
    sudo apt update -y
    sudo apt install apache2 -y
    sudo system start apache2
    sudo echo "I First Server With Terraform" > /var/www/html/index.html'
    echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web-server"
  }
}