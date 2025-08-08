variable "aws_region" {
description = "AWS region for deployment"
type= string
default= "us-east-1"
}
variable "project_name" {
description = "Name prefix for all resources"
type= string
default= "phoenix-defense"
}
variable "instance_type" {
description = "EC2 instance type"
type= string
default= "t2.micro"
}
variable "alarm_threshold" {
description = "CPU threshold to trigger Phoenix protocol"
type= number
default= 80
}