# declare a provider
provider "aws" {
  profile = "default"
}

# create the vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name = "${var.project_name}-main"
  }
}

# data block to get the availability zones

data "aws_availability_zones" "available" {}

# create the subnets
# private subnet

resource "aws_subnet" "private-subnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet1"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet2"
  }
}

# public subnet

resource "aws_subnet" "public-subnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[3]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet2"
  }
  
}

# create the internet gateway, route table and route table association
# internet gateway

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-main-igw"
  }
}

# public subnet route table

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

# public subnet route table association

resource "aws_route_table_association" "public-subnet1-rt-assoc" {
  subnet_id = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-subnet-rt.id
}

resource "aws_route_table_association" "public-subnet2-rt-assoc" {
  subnet_id = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-subnet-rt.id
}

# create the nat gateway, route table and route table association
# elastic ip

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# nat gateway

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public-subnet1.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

# private subnet route table

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

# private subnet route table association

resource "aws_route_table_association" "private-subnet1-rt-assoc" {
  subnet_id = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-subnet-rt.id
}

resource "aws_route_table_association" "private-subnet2-rt-assoc" {
  subnet_id = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-subnet-rt.id
}

# create the security groups
# bastion security group

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

# private subnet security group

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

# alb security group

resource "aws_security_group" "alb-sg" {
  name = "${var.project_name}-alb-sg"
  description = "Allow http and https inbound and all outbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
      description = "HTTP from VPC"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      security_groups = [ aws_security_group.sg.id ]
    }

  ingress {
      description = "HTTPS from VPC"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      security_groups = [ aws_security_group.sg.id ]
    }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# create the key pair, private key and public key
# key pair protocol

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# key pair

resource "aws_key_pair" "key_pair" {
  key_name = "${var.project_name}-key-pair"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# private key

resource "local_file" "priv-key" {
  content = tls_private_key.rsa_key.private_key_pem
  filename = "${var.project_name}-key-pair.pem"
}

# data block to get the ubuntu ami

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

# create the ec2 instances
# bastion

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id = aws_subnet.public-subnet1.id
  user_data = file("userdata.sh")

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# private ec2 instances
# ec2a

resource "aws_instance" "private-ec2a" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.private-subnet1.id

  tags = {
    Name = "${var.project_name}-private-ec2a"
  }
}

# ec2b

resource "aws_instance" "private-ec2b" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.private-subnet2.id

  tags = {
    Name = "${var.project_name}-private-ec2b"
  }
}

# create the load balancer, target group, target group attachments and listener
# load balancer

resource "aws_lb" "alb" {
  name = "${var.project_name}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]

  tags = {
    Name = "${var.project_name}-alb"
  }
  
}

# target group

resource "aws_lb_target_group" "alb-tg" {
  name = "${var.project_name}-alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-alb-tg"
  }
}

# target group attachments

resource "aws_lb_target_group_attachment" "alb-tg-attachment1" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id = aws_instance.private-ec2a.id
  port = 80
}

resource "aws_lb_target_group_attachment" "alb-tg-attachment2" {
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id = aws_instance.private-ec2b.id
  port = 80
}

# listener

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb-tg.arn
    type = "forward"
  }
}