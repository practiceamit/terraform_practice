provider "aws" {
  region     = "us-west-1"
 # access_key = "AKIASCP4SVC6PHGSNMLK"
 # secret_key = "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"
}





resource "aws_vpc" "amitvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "amitvpc"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.amitvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.amitvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}



