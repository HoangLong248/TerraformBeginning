
output "elastic-ip" {
    value = aws_eip.one.public_ip
    description = "Public IP"
}

output "public-dns-name" {
    value = aws_eip.one.public_dns
    description = "Public dns name"
}