resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Permite trafico HTTP al ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Trafico HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo el trafico de salida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-alb-govench"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "alb-govench"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "alb-govench"
  }
}

# Target Group para Lambda
resource "aws_lb_target_group" "lambda_tg" {
  name        = "tg-govench-lambda"
  target_type = "lambda"

  health_check {
    enabled             = true
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener del ALB (Puerto 80 HTTP)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}
