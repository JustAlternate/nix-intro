terraform {
  backend "s3" {
    bucket         = "justalternate-multi-project-tfstate-bucket"
    key            = "ec2_fleet.tfstate"
    region         = "eu-west-3"
  }

	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

provider "aws" {
	region = "eu-west-3"
}

data "aws_ami" "nixos_arm64" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/24.11*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"] # or "x86_64"
  }
}

resource "aws_instance" "instance" {
  count         = 2
  ami           = data.aws_ami.nixos_arm64.id 
  instance_type = "t4g.small"
  key_name      = "justalternate-ssh-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_ssh_all_out.id]
  root_block_device {
      volume_size = 10
  }
}

resource "aws_key_pair" "my_ssh_key" {
  key_name   = "justalternate-ssh-key-pair"
  public_key = file("~/.ssh/id_ed25519.pub")
}

output "instance_ips" {
  value = aws_instance.instance[*].public_ip
}
