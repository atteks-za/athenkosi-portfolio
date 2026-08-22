variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "mini-msp-ops"
}

variable "my_ip" {
  description = "Your public IP in CIDR format, e.g. 1.2.3.4/32"
  type        = string
}