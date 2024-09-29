output "subnet_id" {
  value = "${aws_subnet.private.id}"
}

output "subnet_arn" {
  value = "${aws_subnet.private.arn}"
}
