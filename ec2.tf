# EC2 instance creation
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  for_each               = toset(aws_subnet.public_subnet[*].id)
  subnet_id              = each.key
  iam_instance_profile   = "EC2_SSM_Role"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data              = <<EOF
  apt-get update
  apt-get install nginx -y
  service nginx start
  service nginx enable
  service nginx status
  EOF
  tags = {
    Name = "${var.project_name}-${var.env_name}-web-server"
  }
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