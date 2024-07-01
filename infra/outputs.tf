output "application" {
  value = "http://${aws_lb.lab.dns_name}"
}

output "metrics" {
  value = "http://${aws_lb.lab.dns_name}/metrics"
}

output "prometheus" {
  value = "http://${aws_lb.monitoring.dns_name}/graph"
}

output "grafana" {
  value = "http://${aws_lb.monitoring.dns_name}:3000"
}