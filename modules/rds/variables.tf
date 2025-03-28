variable "password" {
  type = string
}

variable "db_name" {
  type    = string
  default = "myfirstdb"
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "engine_version" {
  type    = string
  default = "8.0.40"
}

variable "vpc_id" {
  type = string
}


variable "my_ip" {
  type = string
}
