output "application_endpoint" {
  value = "http://${aws_lb.lab.dns_name}"
}

output "application_endpoint_metrics" {
  value = "http://${aws_lb.lab.dns_name}/metrics"
}

output "asg_name" {
  value = aws_autoscaling_group.lab.name
}

output "prometheus_endpoint" {
  value = "http://${aws_instance.prometheus.public_dns}/graph"
}

output "prometheus_endpoint_grafana" {
  value = "http://${aws_instance.prometheus.public_dns}:3000"
}

output "prometheus_endpoint_node-exporter" {
  value = "http://${aws_instance.prometheus.public_dns}:9100"
}

output "prometheus_endpoint_containers" {
  value = "http://${aws_instance.prometheus.public_dns}:8080/containers/"
}
