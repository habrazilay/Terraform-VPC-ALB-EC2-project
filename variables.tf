variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "access_key" {}

variable "secret_key" {}

variable "key_name" {}

variable "private_key_path" {}

variable "region" {
    description = "The AWS region to use to create resources."
    default = "us-east-1"
}

variable "bucket_prefix" {
    type        = string
    description = "(required since we are not using 'bucket') Creates a unique bucket name beginning with the specified prefix"
    default     = "my-s3bucket-"
}

variable "acl" {
  default = "private"
}

variable "availability_zones" {
  default = ["us-east-1b", "us-east-1c", "us-east-1d", "us-east-1b","us-east-1f"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
  default = "10.10.0.0/16"
}

variable "ssh_private_key" {
  description = "pem file of Keypair we used to login to EC2 instances"
  type        = string
  default     = "./terraform.pem"
}