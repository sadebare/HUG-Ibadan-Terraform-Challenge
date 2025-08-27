output "application_url" {
  description = "The URL of the web application"
  value       = "http://${module.compute.alb_dns_name}"
}