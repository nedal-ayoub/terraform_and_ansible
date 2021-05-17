
provider "aws" {
  region     =  var.region
}

resource "aws_vpc" "homework4_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "homework4_vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.homework4_vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "homework4_vpc_public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.homework4_vpc.id
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.homework4_vpc.id
  cidr_block = var.subnet_p_cidr

  tags = {
    Name = "homework4_vpc_private"
  }
}


resource "aws_route_table" "rt_homework4_vpc_public" {
  vpc_id = aws_vpc.homework4_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt_homework4_vpc_public"
  }
}

resource "aws_route_table_association" "public_association" {
 subnet_id = aws_subnet.public.id
 route_table_id = aws_route_table.rt_homework4_vpc_public.id
}

resource "aws_security_group" "allow_hw4" {
  name = "allow_hw4_traffic"
  description = "Allow inbound web traffic"
  vpc_id = aws_vpc.homework4_vpc.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = ["::/0"]
    description = "All networks allowed"
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = ["::/0"]
    description = "All networks allowed"
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}
resource "aws_key_pair" "terraform-keys" {
  key_name = "terraform-keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLlsiKhNzFM5Wu9p3zfue3MfFAj5Lu2jhtMsS4UbKKq3RhQ7R68gvKoX+G7ERDatx5VxZxSfSx3KL0HQBRj4I3pmVtuQQmfT1G9nHotYrsBylEg0Y8L4DQyNTnkiipK9mKa1IYKa32ryumV9UNHlIhdBYV6Tvb0iqRq+Z6CAUWHSiGAu3VrxnGnjosQi6Np5Zwl59hIxSA+jseE9bCJpS/Sp+MP4O70OiCDUoKzxM+EvBGdzwNnxLQkbIsIgHBUQlGx+2aP/Oa6+RyKzFL2BIyA4kYjUPVkRdMvuVb9NSlRibgu0giN+f+Gfj5AqOpqX8Iv+gbYzYSBqbKKzFe+NtR 97254@DESKTOP-N4BJT28"
}

module "mysql_Instance" {
  source = "./modules/mysql_Instance"
  image_id           = var.image_id
  keys_name = aws_key_pair.terraform-keys.key_name
  subnet       = aws_subnet.public.id
  security_groups = [aws_security_group.allow_hw4.id] 
}

module "wordpress_instance" {
  source = "./modules/wordpress_instance"
  image_id           = var.image_id
  subnet       = aws_subnet.public.id
  keys_name = aws_key_pair.terraform-keys.key_name
  security_groups = [aws_security_group.allow_hw4.id] 
  mysql_ip = module.mysql_Instance.mysql-pr-ip
}



