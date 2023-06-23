variable "vpc_cidr" {
  description = "cidr range for VPC"
}

variable "env_name" {
  description = "name of the environment"
}

variable "project_name" {
  description = "name of the project"
}

variable "web_ingress_port" {
  description = "web server inbound ports"
  type        = list(any)
}

variable "build_project_name" {
  description = "build project name"
}

variable "cluster_name" {
  description = "ECS cluster name"
}

variable "service_name" {
  description = "ECS service name"
}