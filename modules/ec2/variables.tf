variable "ami_id" {
  type    = string
  default = "ami-0eb070c40e6a142a3"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


variable "vpc_id" {
  type = string
}


variable "connection_ip" {
  type = string
}

variable "security_group_name" {
  type    = string
  default = "mysecuritygroup"
}

variable "subnet_id" {
  type = string
}


variable "key_name" {
  type = string
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_volume_size" {
  type    = number
  default = 8
}

variable "root_iops" {
  type    = number
  default = 3000
}

variable "environment" {
  type    = string
  default = "test"
}

variable "app_name" {
  type    = string
  default = "myfirst_ec2"
}
