provider "aws" {
  access_key = "ACCESS_KEY_ID"
  secret_key = "SECRET_KEY_ID"
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

resource "aws_security_group" "allow_ssh" {
  name        = "allow_all_ssh"
  description = "Allow all inbound ssh traffic "
  tags = {
    Name = "SAI-Security-Group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
