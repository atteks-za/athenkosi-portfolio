# Create an Application Load Balancer in the public subnet
# resource "aws_lb" "terraform_lb" {
#   name               = "terraform-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.terraform_lb_sg.id]
#   subnets            = module.vpc.public_subnets
#
#   enable_deletion_protection = false
#   enable_http2               = true
#
#   tags = {
#     Name = "terraform-load-balancer"
#   }
# }
#
# # Create a Security Group for the Load Balancer
# resource "aws_security_group" "terraform_lb_sg" {
#   name        = "terraform_lb_sg"
#   description = "Allow HTTP and HTTPS traffic to the load balancer"
#   vpc_id      = module.vpc.vpc_id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "terraform_lb_sg"
#   }
# }
#
# # Create a Target Group for the Load Balancer
# resource "aws_lb_target_group" "terraform_target_group" {
#   name     = "terraform-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
#
#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold    = 2
#     unhealthy_threshold  = 2
#   }
#
#   tags = {
#     Name = "terraform-target-group"
#   }
# }
#
# # Create a Listener for the Load Balancer
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.terraform_lb.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.terraform_target_group.arn
#   }
# }
#
# # Register EC2 Instances with the Target Group
# resource "aws_lb_target_group_attachment" "ec2_attachment" {
#   count             = 1
#   target_group_arn  = aws_lb_target_group.terraform_target_group.arn
#   target_id         = aws_instance.terraform_ec2.id
#   port              = 80
# }
