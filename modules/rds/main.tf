
resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Port 3306 access"
    cidr_blocks = [var.my_ip]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
}




resource "aws_db_instance" "myfirtsdb" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = var.password
  skip_final_snapshot    = true
  deletion_protection    = true
  publicly_accessible    = true
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}
