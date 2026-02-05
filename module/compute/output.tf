output "web_security_group_id" {
  value = aws_security_group.web_sg.id
}

output "launch_template_id" {
  value = aws_launch_template.web.id
}

output "asg_name" {
  value = aws_autoscaling_group.web.name
}
