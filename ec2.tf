# EC2 instance creation
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  for_each               = { one = aws_subnet.public_subnet[0].id, two = aws_subnet.public_subnet[1].id }
  subnet_id              = each.value
  iam_instance_profile   = "EC2_SSM_Role"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  key_name               = "web_server"
  tags = {
    Name = "${var.project_name}-${var.env_name}-web-server"
  }
  /*connection {
    type        = "ssh"
    port        = 22
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("web.pem")
  }
  provisioner "remote-exec" {
    inline = ["#!/bin/bash", "sudo apt-get update", "sudo apt-get install nginx -y", "sudo service nginx start", "sudo service nginx enable", "sudo service nginx status"]
  }*/
}

# Security group creation
resource "aws_security_group" "web_server_sg" {
  description = "allowed http and https traffic"
  name        = "web_server_sg"
  vpc_id      = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = toset(var.web_ingress_port)
    iterator = ingress_port
    content {
      from_port   = ingress_port.key
      to_port     = ingress_port.key
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_${var.env_name}_web_server_sg"
  }
}