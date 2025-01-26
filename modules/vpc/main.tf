resource "aws_vpc" "myfirstvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Environment = var.environment
    Name        = var.name
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.myfirstvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region_name}a"

  tags = {
    Name = "${var.private_subnet_name}_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.myfirstvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region_name}b"


  tags = {
    Name = "${var.private_subnet_name}_2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.myfirstvpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "${var.region_name}a"

  tags = {
    Name = "${var.public_subnet_name}_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.myfirstvpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "${var.region_name}b"


  tags = {
    Name = "${var.public_subnet_name}_2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myfirstvpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myfirstvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.public_route_table_name
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip_nat_gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = var.nat_gateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myfirstvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = var.private_route_table_name
  }
}


resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
