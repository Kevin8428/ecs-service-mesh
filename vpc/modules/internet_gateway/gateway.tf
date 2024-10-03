##### public routing #####

resource "aws_internet_gateway" "public_gateway" {
  vpc_id = var.vpc.id
}

# # public subnet NAT gateway
# resource "aws_eip" "nat_gateway" {
#   domain     = "vpc"
#   depends_on = [aws_internet_gateway.public_gateway]
# }

# # gets EIP and must be on public subnet
# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.nat_gateway.id
#   subnet_id     = aws_subnet.public.id
#   tags          = { Name = "poc-public" }
#   depends_on    = [aws_internet_gateway.public_gateway]
# }

# # for IGW
# resource "aws_route_table" "public" {
#   vpc_id = var.vpc.id
#   tags   = { Name = "poc-public" }
# }

# # associate public routing table with public subnet
# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route" "public_route" {
#   route_table_id         = aws_route_table.public.id
#   gateway_id             = aws_internet_gateway.public_gateway.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_subnet" "public" { # public
#   availability_zone               = "us-west-2a"
#   cidr_block                      = cidrsubnet(var.vpc.cidr_block, 4, 2)
#   ipv6_cidr_block                 = cidrsubnet(var.vpc.ipv6_cidr_block, 8, 2)
#   vpc_id                          = var.vpc.id
#   assign_ipv6_address_on_creation = true
#   tags = {
#     Name = "poc-public"
#   }

#   lifecycle {
#     prevent_destroy = false
#   }
# }

# ##### private routing #####

# # for NAT GW
# resource "aws_route_table" "private" {
#   vpc_id = var.vpc.id
#   tags   = { Name = "poc-private" }
# }

# # associate private routing table with private subnet
# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.poc.id
#   route_table_id = aws_route_table.private.id
# }

# # Route private traffic through public subnet via nat gateway
# resource "aws_route" "nat_gateway_route" {
#   route_table_id         = aws_route_table.private.id
#   nat_gateway_id         = aws_nat_gateway.nat_gateway.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_subnet" "poc" { # private
#   availability_zone       = "us-west-2a"
#   vpc_id                  = var.vpc.id
#   cidr_block              = cidrsubnet(var.vpc.cidr_block, 4, 1)
#   ipv6_cidr_block         = cidrsubnet(var.vpc.ipv6_cidr_block, 8, 1)
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "poc-private"
#   }

#   lifecycle {
#     prevent_destroy = false
#   }
# }