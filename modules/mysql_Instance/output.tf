
output "mysql-p-ip" {
  value = aws_instance.mysql-public.public_ip
}
output "mysql-pr-ip" {
  value = aws_instance.mysql-public.private_ip
}
