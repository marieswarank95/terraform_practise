output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "ngw_id" {
  value = aws_nat_gateway.ngw[*].id
}

output "public_subnet_rt_id" {
  value = aws_route_table.public_subnet_rt.id
}

output "private_subnet_az1_rt_id" {
  value = aws_route_table.private_subnet_rt_az1.id
}

output "private_subnet_az2_rt_id" {
  value = aws_route_table.private_subnet_rt_az2.id
}

output "az_list" {
  value = slice(data.aws_availability_zones.us-east-1_az.names, 0, 2)
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "web_server_id" {
  value = aws_instance.web_server[*].id
}