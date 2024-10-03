output "subnet_id" {
  value = "${aws_subnet.s.id}"
}

output "subnet_arn" {
  value = "${aws_subnet.s.arn}"
}

output "nat_gateway_id" {
    value = aws_nat_gateway.ng.id
}