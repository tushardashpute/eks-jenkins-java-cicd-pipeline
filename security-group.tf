resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "worker_mgmt"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description       = "Allow inbound traffic from private networks"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "ingress"
  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
  description       = "Allow outbound traffic to internet"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
