provider "aws" {
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = "${var.project_name}-main"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-main-igw"
  }
}

resource "aws_route_table" "public-subnet-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "${var.project_name}-public-subnet-rt"
  }
}

resource "aws_route_table_association" "public-subnet-rt-assoc" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-subnet-rt.id
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public-subnet.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

resource "aws_route_table" "private-subnet-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "${var.project_name}-private-subnet-rt"
  }
}

resource "aws_route_table_association" "private-subnet-rt-assoc" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-subnet-rt.id
}

resource "aws_security_group" "bastion-sg" {
  name = "${var.project_name}-bastion-sg"
  description = "Allow ssh and icmp inbound and all outbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
      description = "SSH from VPC"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
      description = "ICMP from VPC"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "${var.project_name}-bastion-sg"
    }
}

resource "aws_security_group" "sg" {
  name = "${var.project_name}-sg"
  description = "Allow ssh and icmp inbound and all outbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
      description = "SSH from VPC"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = [ aws_security_group.bastion-sg.id ]
    }

  ingress {
      description = "ICMP from VPC"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      security_groups = [ aws_security_group.bastion-sg.id ]
    }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.project_name}-key-pair"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "priv-key" {
  content = tls_private_key.rsa_key.private_key_pem
  filename = "${var.project_name}-priv-key.pem"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id = aws_subnet.public-subnet.id
  user_data = file("userdata.sh")

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_instance" "private-ec2a" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.private-subnet.id

  tags = {
    Name = "${var.project_name}-private-ec2a"
  }
}

resource "aws_instance" "private-ec2b" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.private-subnet.id

  tags = {
    Name = "${var.project_name}-private-ec2b"
  }
}