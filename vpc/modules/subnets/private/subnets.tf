data "aws_vpc" "main" {
    id = "vpc-bd089fc5" # TODO: need to inject from Make
}

resource "aws_subnet" "private" {
  availability_zone = var.availability_zone
  cidr_block = var.cidr_block
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "intelycare-private-${var.availability_zone}"
    Environment = "dev"
  }

  lifecycle {
    prevent_destroy = true
  }
}
