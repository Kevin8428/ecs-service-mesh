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

# for IGW
resource "aws_route_table" "rt" {
  vpc_id = var.vpc.id
  tags   = { Name = "poc-public" }
}

# associate public routing table with public subnet
resource "aws_route_table_association" "t" {
  subnet_id      = aws_subnet.s.id
  route_table_id = aws_route_table.rt.id
}

# route traffic from public subnet via internet gateway
resource "aws_route" "r" {
  route_table_id         = aws_route_table.rt.id
  gateway_id             = var.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# public subnet NAT gateway
resource "aws_eip" "ng" {
  domain     = "vpc"
  depends_on = [var.internet_gateway]
}

# gets EIP and must be on public subnet
resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.ng.id
  subnet_id     = aws_subnet.s.id
  tags          = { Name = "poc-public" }
  depends_on    = [var.internet_gateway]
}