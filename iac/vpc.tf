# VPC Configuration
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true  # Enable DNS hostnames
  enable_dns_support   = true  # Enable DNS support

  tags = {
    Name = "main-vpc"
  }
}

# ✅ RESTRINGIR DEFAULT SECURITY GROUP (CKV2_AWS_12)
data "aws_security_group" "default_vpc_sg" {
  name   = "default"
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_default_security_group" "default_deny_all" {
  vpc_id = aws_vpc.main_vpc.id

  ingress = []  # No permite entrada
  egress  = []  # No permite salida

  lifecycle {
    ignore_changes = [tags]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false  # Auto-assign public IP

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false  # Auto-assign public IP

  tags = {
    Name = "public-subnet-b"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Configuración de VPC Flow Logs
resource "aws_flow_log" "main_vpc_flow_log" {
  vpc_id           = aws_vpc.main_vpc.id
  traffic_type     = "ALL"
  log_group_name   = "/aws/vpc/flow-logs"
  iam_role_arn     = aws_iam_role.flow_logs_role.arn
}

# Rol de IAM para VPC Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "flow_logs_policy" {
  name = "vpc-flow-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:us-east-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flow-logs:*"
        ]
      }
    ]
  })
}

# Adjuntar la política al rol de VPC Flow Logs
resource "aws_iam_role_policy_attachment" "flow_logs_policy_attachment" {
  role       = aws_iam_role.flow_logs_role.name
  policy_arn = aws_iam_policy.flow_logs_policy.arn
}
