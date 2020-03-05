# Security Group
resource "aws_security_group" "lb_sg" {
  name = "awtest_lb_sg"
  vpc_id = "${var.test_vpc}"
  description = "My Test Security Group"
  tags {
    "Name" = "My_LB_SG"
  }
}

# A Security Group Rule assigned to the above security group
resource "aws_security_group_rule" "my_lb_rule" {
  type = "egress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  security_group_id = "${aws_security_group.lb_sg}"
  cidr_blocks = "0.0.0.0/0"
  description = "HTTPS outbound access from LB"
}
