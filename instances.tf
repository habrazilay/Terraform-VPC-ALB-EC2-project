resource "aws_instance" "web-red" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet3.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  //iam_instance_profile = aws_iam_instance_profile.SSMRoleForEC2.name
  user_data = filebase64("./ec2_red.sh")

  tags = {
    "Name" = "EC2-Instance-Red"
  }
}

resource "aws_instance" "web-blue" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet4.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  user_data = filebase64("./ec2_blue.sh")

  tags = {
    "Name" = "EC2-Instance-Blue"
  }
}
