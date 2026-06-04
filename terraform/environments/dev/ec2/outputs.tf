output "instance_id" {
  value = aws_instance.dev.id
}

output "private_ip" {
  value = aws_instance.dev.private_ip
}
