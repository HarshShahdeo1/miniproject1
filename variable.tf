variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.124.0.0/16"
}

variable "access_ip" {
  description = "The IP address allowed to access the resources"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t3.micro"
}

variable "main_instance_count" {
  description = "The number of main instances to create"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "id_rsa_project"
}

variable "public_key_path" {
  description = "Path to the public key file on the Jenkins server"
  type        = string
  default     = "/var/lib/jenkins/.ssh/id_rsa_project.pub"
}

variable "private_key_path" {
  description = "Path to the private key file on the Jenkins server"
  type        = string
  default     = "/var/lib/jenkins/.ssh/id_rsa_project"
}