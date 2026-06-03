output "instance_id" {
  description = "Production EC2 instance ID."
  value       = aws_instance.app.id
}

output "private_ip" {
  description = "Private IP address."
  value       = aws_instance.app.private_ip
}

output "security_group_id" {
  description = "EC2 security group ID."
  value       = aws_security_group.ec2.id
}
