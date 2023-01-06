# Configure the AWS Provider
provider "aws" {
    profile = "myprofile"
    region = "us-east-1"
}

resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
}

resource "aws_vpc" "second-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "dev"
    }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.second-vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "dev-subnet"
  }
}

# resource "<provider>_<resource_type>" "name" {
#     config options ...
#     key = "value"
#     key2 = "another value"
# }