
provider "aws" {
  region = "eu-west-1"
}

variable "vpc_id" {
  default = "vpc-0fce7c0976c3a6beb"
}

variable "subnet_id" {
  default = "subnet-08a10285030552635"
}

variable "key_name" {
  default = "workshop-fcloud"
}

data "template_file" "init" {
 template = "${file("userdata.tpl")}"
 vars = {
   username = "fcloud"
 }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server*"]
  }
}

resource "aws_security_group" "web" {
  vpc_id      = "${var.vpc_id}"
  name        = "web"
  description = "Allow web traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web"
  }
}

resource "aws_instance" "webapp" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${var.subnet_id}"
  key_name      = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  user_data     = "${data.template_file.init.rendered}"
  tags = {
    Name = "webapp"
  }
}
