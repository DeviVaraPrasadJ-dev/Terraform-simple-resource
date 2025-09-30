provider "aws" {
  region = var.region
}

resource "aws_instance" "Jenkins-TF-Instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Jenkins-TF-Instance"
  }
}
