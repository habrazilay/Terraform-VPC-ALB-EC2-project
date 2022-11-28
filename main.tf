terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.65.0"
    }
  }
}

# Provider
provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#############################################

#Creating Virtual Private Cloud:

#############################################
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
}

#############################################

# Creating Public subnets:

#############################################
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet1"
    Type = "Public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet2"
    Type = "Public"
  }
}

#############################################

# Creating Private subnets:

#############################################
resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Subnet3"
    Type = "Private"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Subnet4"
    Type = "Private"
  }
}

#############################################

# Creating Internet Gateway:

#############################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name"  = "Main"
  }
}

#############################################

# Creating NAT:

#############################################
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

#############################################

# Creating Public Route:

#############################################
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public"
  }
}

#############################################

# Creating Private Route:

#############################################
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private"
  }
}

#############################################

# Creating Public Route Table Association:

#############################################
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt1.id
}

#############################################

# Creating Private Route Table Association:

#############################################
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.rt2.id
}

#############################################

# Creating Webserver Security group:

#############################################
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "webserver network traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22  
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      cidrsubnet(var.cidr_block, 8, 1),
      cidrsubnet(var.cidr_block, 8, 2)
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow traffic"
  }
}

#############################################

# Creating Load Balancer Security group:

#############################################
resource "aws_security_group" "alb" {
  name        = "alb"
  description = "alb network traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.webserver.id]
  }

  tags = {
    Name = "allow traffic"
  }
}

#############################################

# Creating S3 Bucket:

#############################################

resource "aws_s3_bucket" "my-s3-bucket" {
    bucket_prefix = var.bucket_prefix
    acl    = var.acl 
}

resource "aws_s3_bucket_object" "red-folder" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    key = "red/"
    source = "/dev/null"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "blue-folder" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    key = "blue/"
    source = "/dev/null"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "red-object" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    key = "red/index.html"
    source = "html/red/index.html"
    etag = filemd5("./html/red/index.html")
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "blue-object" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    key = "blue/index.html"
    source = "html/blue/index.html"
    etag = filemd5("./html/blue/index.html")
    content_type = "text/html"
}

#############################################

# Creating private key pair:

#############################################
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

####################################################
# Application Load balancer
####################################################
resource "aws_alb" "alb1" {
  name               = "alb1"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

####################################################
# Target Groups Creation
####################################################
resource "aws_alb_target_group" "red-tg" {
  name = "red-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_alb_target_group" "blue-tg" {
  name = "blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

####################################################
# Target Group Attachment with Instance
####################################################
resource "aws_alb_target_group_attachment" "red-attachment" {
  target_group_arn = aws_alb_target_group.red-tg.arn
  target_id        = aws_instance.web-red.id
}

resource "aws_alb_target_group_attachment" "blue-attachment" {
  target_group_arn = aws_alb_target_group.blue-tg.arn
  target_id        = aws_instance.web-red.id
}

####################################################
# Listener
####################################################
resource "aws_alb_listener" "http-front-end" {
  load_balancer_arn  = aws_alb.alb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_alb_target_group.red-tg.arn
      }

      target_group {
        arn = aws_alb_target_group.blue-tg.arn
      }

      stickiness {
        enabled  = true
        duration = 28800
      }
    }
  }
}

####################################################
# Listener Rules
####################################################
resource "aws_alb_listener_rule" "red-rule" {
  listener_arn = aws_alb_listener.http-front-end.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.red-tg.arn
  }

  condition {
    path_pattern {
      values = ["/red"]
    }
  }
}

resource "aws_alb_listener_rule" "blue-rule" {
  listener_arn = aws_alb_listener.http-front-end.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.blue-tg.arn
  }

  condition {
    path_pattern {
      values = ["/blue"]
    }
  }
}