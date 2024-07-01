output "server" {
  value = "http://${aws_lb.server.dns_name}"
}