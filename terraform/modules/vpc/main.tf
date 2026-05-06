resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name        = "${var.project}-${var.env}-vpc"
    Environment = var.env
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project}-${var.env}-igw"
    Environment = var.env
  }
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 2, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.env}-public-subnet"
    Environment = var.env
  }
}

# --- Public Route Table ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-${var.env}-public-rt"
    Environment = var.env
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 2, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.project}-${var.env}-private-subnet"
    Environment = var.env
  }
}

# --- NAT Gateway (only when enable_nat_gateway = true) ---
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "${var.project}-${var.env}-nat-eip"
    Environment = var.env
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name        = "${var.project}-${var.env}-nat-gw"
    Environment = var.env
  }

  depends_on = [aws_internet_gateway.this]
}

# --- Private Route Table ---
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = {
    Name        = "${var.project}-${var.env}-private-rt"
    Environment = var.env
  }
}

resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private[0].id
}
