resource "aws_subnet" "public" {
  vpc_id     = "${var.test_vpc}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "My_Public_Subnet"
  }
}

# required for terraform remote state calls
output "subnet_id" {
  value = ["${aws_subnet.public.id}"]
}