terraform {
  required_version = ">=1.2.0, <2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http.id]
  subnets            = var.subnets_ids
}

resource "aws_lb_listener" "http" {
  count             = var.enable_https ? 0 : 1
  load_balancer_arn = aws_lb.this.arn
  port              = local.http_port
  protocol          = local.lb_http_protocol
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = local.https_port
  protocol          = local.lb_https_protocol
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  lifecycle {
    precondition {
      condition     = var.certificate_arn != null
      error_message = "Certificate ARN must be set when enable_https is true"
    }
  }
}

resource "aws_lb_listener" "redirect_to_https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = local.http_port
  protocol          = local.lb_http_protocol
  default_action {
    type = "redirect"

    redirect {
      port        = local.https_port
      protocol    = local.lb_https_protocol
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "http" {
  name = "${var.name}-http"
}

resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.http.id
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.any_ip
}

resource "aws_security_group_rule" "allow_https" {
  count             = var.enable_https ? 1 : 0
  security_group_id = aws_security_group.http.id
  type              = "ingress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.any_ip
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.http.id
  type              = "egress"
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.any_ip
}

locals {
  http_port         = 80
  https_port        = 443
  tcp_protocol      = "tcp"
  lb_http_protocol  = "HTTP"
  lb_https_protocol = "HTTPS"
  any_port          = 0
  any_protocol      = "-1"
  any_ip            = ["0.0.0.0/0"]
}