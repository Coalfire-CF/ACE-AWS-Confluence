output "confluence_instance_sg_id" {
  value       = aws_security_group.confluence_instance_sg.id
  description = "Confluence Security Group ID"
}
