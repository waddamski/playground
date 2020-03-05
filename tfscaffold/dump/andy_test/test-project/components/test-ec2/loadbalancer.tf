resource "aws_lb" "aw_test_lb" {
  name               = "aw-test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets            = ["${aws_subnet.public.id}"]
  enable_deletion_protection = true
  tags = {
    Environment = "awtest"
  }
}