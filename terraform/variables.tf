variable "aws_region" {
  # AWS region used by the provider and the remote state backend.
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  # EC2 size used by every web server in this lab.
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  # Existing AWS EC2 key pair used for administrative SSH access.
  description = "AWS key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  # CIDR allowed to reach SSH; CI restricts it to the current runner IP.
  description = "CIDR allowed to access SSH"
  type        = string
}