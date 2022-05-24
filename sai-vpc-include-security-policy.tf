provider "aws" {
  access_key = "access_key"
  secret_key = "secret_key"
  region     = "ap-southeast-1"
}

variable "ec2-key" {}

variable "ami"{
    default="ami-0bd6906508e74f692"
}

resource "aws_vpc" "SAI-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "SAI-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.SAI-vpc.id}"
  tags = {
    Name = "Sai-Internet-Gateway"
  }

}

resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.SAI-vpc.id}"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.SAI-vpc.id}"
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "public-subnet"
  }
  
}

resource "aws_route_table" "public-rt" {
  vpc_id     = "${aws_vpc.SAI-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_security_group" "allow_ssh_ping_all" {
  name        = "allow_all_ssh_ping_all"
  description = "Allow all inbound all traffic and Ping "
  tags = {
    Name = "SAI-Security-Group"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #allow all inbound tcp
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] #allow all inbound icmp_ping
  }
  ingress {
    from_port   = 33434
    to_port     = 33434
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] #allow  inbound udp 33434
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allow all outbound tcp
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  #allow all outbound icmp
  }
  egress {
    from_port   = 33434
    to_port     = 33434
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  #allow udp_33434 outbound tcp
  }
}

resource "aws_instance" "web-server" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.ec2-key}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  tags = {
    Name = "Web-Server"
  }

}
