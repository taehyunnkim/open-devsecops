resource "aws_vpc" "lab_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default" 
    
    tags = {
        Name = "lab_vpc"
    }
}

resource "aws_subnet" "lab_public_subnet" {
 vpc_id     = aws_vpc.lab_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = var.availability_zone
 
 tags = {
   Name = "lab_pub_subnet"
 }
}
 
resource "aws_subnet" "lab_private_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zone
 
  tags = {
    Name = "lab_priv_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.lab_vpc.id
 
 tags = {
   Name = "lab_vpc_igw"
 }
}

resource "aws_route_table" "lab_public_route_table" {
 vpc_id = aws_vpc.lab_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
 
 tags = {
   Name = "lab_pub_rt"
 }
}

resource "aws_route_table" "lab_private_route_table" {
 vpc_id = aws_vpc.lab_vpc.id
 
 tags = {
   Name = "lab_priv_rt"
 }
}


resource "aws_route_table_association" "lab_pub_sub_rt"{
    subnet_id = aws_subnet.lab_public_subnet.id
    route_table_id = aws_route_table.lab_public_route_table.id
}

resource "aws_route_table_association" "lab_priv_sub_rt"{
    subnet_id = aws_subnet.lab_private_subnet.id
    route_table_id = aws_route_table.lab_private_route_table.id
}

resource "aws_security_group" "base" {
  # vpc_id = aws_vpc.lab_vpc.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Artifactory"
    from_port        = 8082
    to_port          = 8082
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}