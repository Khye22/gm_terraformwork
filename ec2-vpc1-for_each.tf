provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "clement" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = "jack"
  //security_groups = ["clement-sg"]
  vpc_security_group_ids = [aws_security_group.clement-sg.id]
  subnet_id              = aws_subnet.jack-public-subnet-01.id
for_each = toset (["sonarqube-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
  }
}
resource "aws_security_group" "clement-sg" {
  name        = "clement-sg"
  description = "clement-sg"
  vpc_id      = aws_vpc.jack-vpc.id


  tags = {
    Name = "clement-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sshaccess" {
  security_group_id = aws_security_group.clement-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.clement-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_ipv4" {
  security_group_id = aws_security_group.clement-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_ipv6" {
  security_group_id = aws_security_group.clement-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc" "jack-vpc" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "jack-vpc"
  }
}

resource "aws_subnet" "jack-public-subnet-01" {
  vpc_id                  = aws_vpc.jack-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "jack-public-subnet-01"
  }

}


resource "aws_subnet" "jack-public-subnet-02" {
  vpc_id                  = aws_vpc.jack-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "jack-public-subnet-02"
  }

}

resource "aws_internet_gateway" "jack-igw" {
  vpc_id = aws_vpc.jack-vpc.id

  tags = {
    Name = "jack-igw"
  }

}

resource "aws_route_table" "jack-public-rt" {
  vpc_id = aws_vpc.jack-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jack-igw.id
  }
  tags = {
    Name = "jack_public-rt"
  }
}

resource "aws_route_table_association" "jack-rta-public-subnet-01" {
  subnet_id      = aws_subnet.jack-public-subnet-01.id
  route_table_id = aws_route_table.jack-public-rt.id
}


resource "aws_route_table_association" "jack-rta-public-subnet-02" {
  subnet_id      = aws_subnet.jack-public-subnet-02.id
  route_table_id = aws_route_table.jack-public-rt.id
}