resource "aws_eip" "eip_ec2" {
  domain = "vpc"
}

resource "aws_security_group" "first_security_group" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = var.security_group_name
  }

  ingress {
    description = "Port 22 access"
    cidr_blocks = [var.connection_ip]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "Port 80 access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    description = "Security Group egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "myec2instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  ebs_optimized               = false
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.first_security_group.id]

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    iops        = var.root_iops
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}",
    Environment = var.environment
  }
}


resource "aws_eip_association" "eip_assoc_ec2" {
  instance_id   = aws_instance.myec2instance.id
  allocation_id = aws_eip.eip_ec2.id
}
