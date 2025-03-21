/*

Task 1: Create a VPC with Public & Private Subnets
✅ Objective: Learn about VPC, subnets, and CIDR blocks.
✅ Steps:

Create a VPC with CIDR block 10.0.0.0/16.
Create one public and one private subnet.
Attach an Internet Gateway to allow internet access.
Attach Route Tables for public and private subnets.
Attach Nat gateway.


*/


variable "v_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "v_pub_sn_cidr" {
  type    = list(any)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "v_pvt_sn_cidr" {
  type    = list(any)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "v_azs" {
  type    = list(any)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}

resource "aws_vpc" "VPC11" {
  cidr_block = var.v_vpc_cidr
}

resource "aws_subnet" "pub_sn" {
  count = length(var.v_pub_sn_cidr)

  vpc_id            = aws_vpc.VPC11.id
  cidr_block        = element(var.v_pub_sn_cidr, count.index)
  availability_zone = element(var.v_azs, count.index)

  tags = {
    Name = "publicns"
  }
}

resource "aws_subnet" "pvt_sn" {
  count = length(var.v_pvt_sn_cidr)

  vpc_id            = aws_vpc.VPC11.id
  cidr_block        = element(var.v_pvt_sn_cidr, count.index)
  availability_zone = element(var.v_azs, count.index)

  tags = {
    Name = "privatesns"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC11.id

  tags = {
    Name = "internetgateway1"
  }
}
resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.VPC11.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "sn1rt1" {
  count          = length(var.v_pub_sn_cidr)
  route_table_id = aws_route_table.RT1.id
  subnet_id      = element(aws_subnet.pub_sn.*.id, count.index)

}
resource "aws_eip" "EIP" {
  
}

resource "aws_nat_gateway" "NGW" {
subnet_id = aws_subnet.pvt_sn[0].id
allocation_id =aws_eip.EIP.id
}

resource "aws_route_table" "RT2" {
  vpc_id = aws_vpc.VPC11.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }
}
resource "aws_route_table_association" "sn2rt2" {
  count          = length(var.v_pvt_sn_cidr)
  route_table_id = aws_route_table.RT2.id
  subnet_id      = element(aws_subnet.pvt_sn.*.id, count.index)

}

