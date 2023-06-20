data "aws_availability_zones" "us-east-1_az" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}