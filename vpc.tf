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



resource "aws_security_group" "amitsg" {
  name        = "amitsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.amitvpc.id

  ingress {
      description      = "TLS from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "amitsg"
  }
}

resource "aws_internet_gateway" "amit_igw" {
  vpc_id = aws_vpc.amitvpc.id

  tags = {
    Name = "amit-igw"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.amitvpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.amit_igw.id
    }



  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.amitvpc.id

  route {

      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.amit_natgw.id
    }

  tags = {
    Name = "private_rt"
  }
}


resource "aws_route_table_association" "public_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_route_table_association" "private_asso" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}



#resource "aws_key_pair" "amitkey" {
# key_name   = "amitkey"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOxaXjD+rroVCu62FU0Ou5XtzG1t2wL05pG9ijT2NHsH7Ujf208RIloCiwZq6TUzyaCxpfjQ8rNlK6eS5ObvSg6E8niEvYh157kXrqYIqOnfrHDn3HNFSnCtKfS/3BEjYTzkeOUXtgPBLQj2XZnzTv6380smS2dMeDfvMSBiTDjuTg7CcHT3UlkwIF0LA+3HuE+bfPxs+PIcyR9s7IEuydz5AmfkKvhv46jEv+MEnFRFKcZkHi90suXnnbVmWwcLXjOTMroV0mcA7K1jHUh6mgUAGtEsiC9p+GpSOVyZ8wOOn3CHejI3jemfNV4+j8UZVxoccWYEbgTObp8CTSRqNZ root@ip-172-31-3-194.us-west-1.compute.internal"
#}


#resource "aws_instance" "amit_web" {
# ami           = "ami-0d382e80be7ffdae5"
 # instance_type = "t3.micro"
 # subnet_id     = aws_subnet.public_subnet.id
 # vpc_security_group_ids  = [aws_security_group.amitsg.id]
 # key_name      = "amitkey"
 # tags = {
 #   Name = "amit_web"
 # }
#}


#resource "aws_instance" "amit_db" {
 # ami           = "ami-0d382e80be7ffdae5"
 # instance_type = "t3.micro"
 # subnet_id     = aws_subnet.private_subnet.id
 # vpc_security_group_ids  = [aws_security_group.amitsg.id]

  #  tags = {
   # Name = "amit_db"
#  }
#}

resource "aws_eip" "amit_eip" {
  instance = aws_instance.amit_web.id
  vpc      = true
}


resource "aws_eip" "amitnat_ip" {
   vpc      = true
}



resource "aws_nat_gateway" "amit_natgw" {
  allocation_id = aws_eip.amitnat_ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "gw NAT"
  }

}
