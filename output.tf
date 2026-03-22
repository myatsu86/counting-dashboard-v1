output "dashboard_instance_private_key" {
  description = "Private key for SSH access"
  value       = tls_private_key.counting_dashboard.private_key_openssh
  sensitive   = true
}

output "dashboard_instance_public_ip" {
  description = "Public IP of the dashboard instance"
  value       = aws_instance.dashboard.public_ip
}

output "counting_instance_private_ip" {
  description = "Private IP of the counting instance"
  value       = aws_instance.counting.private_ip
}