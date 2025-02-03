locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group" "lb_sg" {
  name   = var.lb_sg_name
  vpc_id = var.vpc_id


  tags = merge(local.common_tags, {
    Name = "${var.lb_sg_name}"
  })


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

resource "aws_security_group" "bastionhost_sg" {
  name   = var.bastionhost_sg_name
  vpc_id = var.vpc_id

  tags = {
    Name = var.bastionhost_sg_name
  }

  ingress {
    description = "Port 22 access"
    cidr_blocks = [var.connection_ip]
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "ec2_private_instances_sg" {
  name   = var.ec2_private_instances_sg_name
  vpc_id = var.vpc_id

  tags = merge(local.common_tags, {
    Name = var.ec2_private_instances_sg_name
  })

  ingress {
    description     = "Port 22 access from bastion host"
    security_groups = [aws_security_group.bastionhost_sg.id]
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  }

  ingress {
    description     = "Port 80 access"
    security_groups = [aws_security_group.lb_sg.id]
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }

  egress {
    description = "Security Group egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "my_private_ec2_instance" {
  for_each = toset(["a", "b"])

  ami                         = var.ami_id
  instance_type               = var.instance_type
  ebs_optimized               = false
  associate_public_ip_address = false
  key_name                    = var.key_name
  subnet_id                   = each.key == "a" ? var.private_subnet_id_1 : var.private_subnet_id_2
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.ec2_private_instances_sg.id]

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    iops        = var.root_iops
  }

  tags = merge(local.common_tags, {
    Name = "${var.app_name}${each.key}-${var.environment}"
  })
}

resource "aws_instance" "myec2instance_bastionhost" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  ebs_optimized               = false
  associate_public_ip_address = true
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id_1
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.bastionhost_sg.id]

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    iops        = var.root_iops
  }

  tags = merge(local.common_tags, {
    Name = "${var.bastionhost_name}-${var.environment}"
  })
}

resource "aws_eip" "eip_bastionhost" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc_ec2" {
  instance_id   = aws_instance.myec2instance_bastionhost.id
  allocation_id = aws_eip.eip_bastionhost.id
}

resource "aws_lb" "lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]
  ip_address_type    = "ipv4"

  tags = merge(local.common_tags, {
    Name = "${var.lb_name}-${var.environment}"
  })

}

resource "aws_lb_target_group" "app_tg" {
  name            = "app-target-group"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = var.vpc_id
  ip_address_type = "ipv4"

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = merge(local.common_tags, {
    Name = "app-target-group-${var.environment}"
  })
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "instance_attachment" {
  for_each = aws_instance.my_private_ec2_instance

  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = each.value.id
  port             = 80
}
