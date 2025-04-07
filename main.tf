# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "ansible_vpc" {
    cidr_block = "10.1.0.0/16"
}
resource "aws_subnet" "ansible_subent" {
    vpc_id = aws_vpc.ansible_vpc.id
    cidr_block = "10.1.0.0/24"
    map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "ansible_IGW" {
  vpc_id = aws_vpc.ansible_vpc.id
  tags = {
    Name = "ansible"
  }
}
resource "aws_route_table_association" "Sub-RT" {
  subnet_id      = aws_subnet.ansible_subent.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.ansible_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_IGW.id 
  }
  tags = {
    Name = "Route_table"
  }
}
resource "aws_security_group" "Sec_Group" {
  name        = "ansible_group"
  vpc_id      = aws_vpc.ansible_vpc.id

  tags = {
    Name = "ansible_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.Sec_Group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.Sec_Group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
resource "aws_instance" "Ec2" {
  ami                    = data.aws_ami.amzn-linux-2023-ami.id
  instance_type          = "t2.micro"
  key_name               = "vockey"
  subnet_id = aws_subnet.ansible_subent.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.Sec_Group.id]
  tags = {
    Name = "EC2_Terraform"
  }
}

output "ip" {
    value = aws_instance.Ec2.public_ip
  
}
