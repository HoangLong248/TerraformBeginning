# Configure the AWS Provider
provider "aws" {
    profile = "myprofile"
    region = "us-east-1"
}

resource "aws_instance" "my-first-server" {
    ami = "ami-0b93ce03dcbcb10f6"
    instance_type = "t2.micro"
    
}

# resource "<provider>_<resource_type>" "name" {
#     config options ...
#     key = "value"
#     key2 = "another value"
# }