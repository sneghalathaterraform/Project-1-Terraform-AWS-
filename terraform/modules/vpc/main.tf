resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name        = "${var.project}-${var.env}-vpc"
    Environment = var.env
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 2, 0)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project}-${var.env}-public-subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
