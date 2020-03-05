resource "aws_instance" "aw_test_instance" {
  ami           = "ami-09693313102a30b2c"
  instance_type = "t2.micro"
}