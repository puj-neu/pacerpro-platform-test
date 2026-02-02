variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "us-east-1"
  }
  
variable "project_name" {
    description = "Project name for resource naming"
    type = string 
    default = "pacer-pro-platform-test"
}

variable "ec2_ami_id" {
    description = "EC2 AMI ID"
    type = string
}

variable "ec2_instance_type" {
    description = "Ec2 instance type"
    type = string
    default = "t3.micro"
}

variable "alert_email" {
    description = "Alert email"
    type = string
    default = "pkalivarapu@gmail.com"
  
}