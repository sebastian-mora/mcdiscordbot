resource "aws_vpc" "mc_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Minecraft VPC"
  }
}

resource "aws_subnet" "mc_public" {
  vpc_id                  = aws_vpc.mc_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
}
# Create the Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.mc_vpc.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.mc_vpc.id
}

# Create the Internet Access
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = var.public_subnet_cidr
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.mc_public.id
  route_table_id = aws_route_table.route_table.id
} # end resource