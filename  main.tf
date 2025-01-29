module "first_vpc" {
  source = "./modules/vpc"
  name   = "my_first_vpc"
}

module "first_ec2" {
  source        = "./modules/ec2"
  key_name      = var.key_name
  subnet_id     = module.first_vpc.public_subnet_1.id
  vpc_id        = module.first_vpc.vpc.id
  connection_ip = var.connection_ip
}

