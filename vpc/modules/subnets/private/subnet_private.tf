resource "aws_subnet" "s" {
  availability_zone               = var.availability_zone
  cidr_block                      = var.cidr_block
  ipv6_cidr_block                 = var.ipv6_cidr_block
  vpc_id                          = var.vpc.id
  assign_ipv6_address_on_creation = true
  tags                            = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

# for NAT GW
resource "aws_route_table" "rt" {
  vpc_id = var.vpc.id
  tags   = { Name = "poc-private" }
}

# associate private routing table with private subnet
resource "aws_route_table_association" "t" {
  subnet_id      = aws_subnet.s.id
  route_table_id = aws_route_table.rt.id
}

# Route private traffic through public subnet via nat gateway
resource "aws_route" "r" {
  route_table_id         = aws_route_table.rt.id
  nat_gateway_id         = var.nat_gateway_id
  destination_cidr_block = "0.0.0.0/0"
}