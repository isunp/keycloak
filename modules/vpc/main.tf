data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count      = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count      = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-private-${count.index}"
  }
}

resource "aws_security_group" "public" {
  name   = "${var.vpc_name}-public-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "private" {
  name   = "${var.vpc_name}-private-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "db" {
  name   = "${var.vpc_name}-db-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_network_interface" "nat_gw" {
  count     = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public[count.index].id
  security_groups = [
    aws_security_group.public.id
  ]
}

resource "aws_instance" "nat_gw" {
  count         = length(var.public_subnet_cidrs)
  ami           = "ami-0c55b159cbfafe1f0" // Amazon Linux 2 AMI ID
  instance_type = "t2.micro"
  key_name      = "my-key-pair" // Replace with your SSH key pair name
  network_interface {
    network_interface_id = aws_network_interface.nat_gw[count.index].id
    device_index         = 0
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "allow_db_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private.id
  security_group_id        = aws_security_group.db.id
}

resource "aws_eip" "nat_gw" {
  count = length(var.public_subnet_cidrs)
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



