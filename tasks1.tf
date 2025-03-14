provider "aws" {
  region     = "ap-southeast-1"
  access_key = "AKIAVA5YK53HUD3KUJSK"
  secret_key = "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"
}


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