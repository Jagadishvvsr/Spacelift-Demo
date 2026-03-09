provider "aws" {
     region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent      = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

   filter {
    name = "architecture"
    values = ["x86_64"]
   }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}

locals {
 instances = {
   instance1 = {
      instance_type = "t3.micro"
      ami_id = data.aws_ami.ubuntu.id
    }
     
   instance2 = {
      instance_type = "t3.micro"
      ami_id = data.aws_ami.ubuntu.id
   }

   instance3 = {
      instance_type = "t3.micro"
      ami_id = data.aws_ami.ubuntu.id
   }

    }

    ports = [22, 80]
    
}


resource "aws_key_pair" "space_tf_key" {
   key_name = "spacelift.key"
   public_key = file(var.key_file)
}

resource "aws_security_group" "spacelift_SG" {
  name = "spacelift-sg"

  dynamic "ingress" {
    for_each = local.ports

    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
}


resource "aws_instance" "aws_ec2_tf_spacelift" {
    for_each = local.instances
    ami = each.value.ami_id
    instance_type = each.value.instance_type
    key_name = aws_key_pair.space_tf_key.key_name
    vpc_security_group_ids = [aws_security_group.spacelift_SG.id]
    associate_public_ip_address = true
    tags = {
        Name = each.key
    }
}


