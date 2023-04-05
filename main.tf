# Create custom vpc (first ever automation script with terraform)

resource "aws_vpc" "set14-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "set14-vpc"
    created = "Lington"
  }
}

# Create public subnet

resource "aws_subnet" "set14-public-subnet" {
  vpc_id     = aws_vpc.set14-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "set14-public-subnet"
    created = "Lington"
  }
}

# Create internet Gate way

resource "aws_internet_gateway" "set14-igw" {
  vpc_id = aws_vpc.set14-vpc.id

  tags = {
    Name = "set14-igw"
    created = "Lington"
  }
}

# Create public route table
resource "aws_route_table" "set14-RT" {
  vpc_id = aws_vpc.set14-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.set14-igw.id
  }

  tags = {
    Name = "set14-RT"
  }
}

# Create route table association

resource "aws_route_table_association" "set14-RT-Association" {
  subnet_id      = aws_subnet.set14-public-subnet.id
  route_table_id = aws_route_table.set14-RT.id
}

# Create a Security group

resource "aws_security_group" "Front-end-SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.set14-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
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
    Name = "Front-end-SG"
  }
}

resource "aws_s3_bucket" "lington-set14-s3-backend" {
  bucket = "lington-set14-s3-backend"

  tags = {
    Name        = "lington-set14-s3-backend"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "lington-set14-s3-backend-acl" {
  bucket = aws_s3_bucket.lington-set14-s3-backend.id
  acl    = "public-read"
}


resource "aws_instance" "set14" {
  ami           = "ami-0b04ce5d876a9ba29" #Redhat
  instance_type = "t2.micro"   #free tier
  subnet_id     = aws_subnet.set14-public-subnet.id
  vpc_security_group_ids = [aws_security_group.Front-end-SG.id]
  
  associate_public_ip_address = true # without this you can get a public ip address in your instance
  
  key_name = "keypair2"


# resource "aws_key_pair" "keypair2" {
#   key_name   = "keypair2"
#   public_key = file("~/keypair/keypair2.pub") # using absolute path instead of copying the whole public key of key pair
# }


  tags = {
    Name = "set14"
  }
}

