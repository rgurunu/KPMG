#Code to create AWS VPC and asked user to enter VPC CIDR Range and Name 
resource "aws_vpc" "web-vpc" {
  cidr_block  = "${var.vpc_cidr}"
  tags = {
    Name = "web-vpc"
  }
}


#Code to create Data Source of Public Subnet 
data "aws_subnet_ids" "public" {
  depends_on = ["aws_subnet.public"]
  vpc_id     = "${aws_vpc.web-vpc.id}"
  tags = {
    tier = "public"
  }
}

#Code to create Data Source of Web Tier Subnet
data "aws_subnet_ids" "web" {
  depends_on = ["aws_subnet.web"]
  vpc_id     = "${aws_vpc.web-vpc.id}"
  tags = {
    tier = "web"
  }
}

#Code to create Data Source of App Tier Subnet
data "aws_subnet_ids" "app" {
  depends_on = ["aws_subnet.app"]
  vpc_id     = "${aws_vpc.web-vpc.id}"
  tags = {
    tier = "app"
  }
}

#Code to create Data Source of Data Tier Subnet
data "aws_subnet_ids" "data" {
  depends_on = ["aws_subnet.data"]
  vpc_id     = "${aws_vpc.web-vpc.id}"
  tags = {
    tier = "data"
  }
}

#Code to create Public Subnet 
resource "aws_subnet" "public" {
  count             = "${length(var.public_subnets_cidr)}"
  vpc_id            = "${aws_vpc.web-vpc.id}"
  cidr_block        = "${element(var.public_subnets_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Public-Subnet-${count.index+1}"
    tier = "public"
  }
}

#Code to create Web Subnet 
resource "aws_subnet" "web" {
  count             = "${length(var.web_subnets_cidr)}"
  vpc_id            = "${aws_vpc.web-vpc.id}"
  cidr_block        = "${element(var.web_subnets_cidr,count.index)}"
#  map_public_ip_on_launch = "true"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Web-Subnet-${count.index+1}"
    tier = "web"
  }
}

#Code to create App Subnet    
resource "aws_subnet" "app" {
  count             = "${length(var.app_subnets_cidr)}"
  vpc_id            = "${aws_vpc.web-vpc.id}"
  cidr_block        = "${element(var.app_subnets_cidr,count.index)}"
#  map_public_ip_on_launch = "true"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "App-Subnet-${count.index+1}"
    tier = "app"
  }
}

#Code to create data Subnet    
resource "aws_subnet" "data" {
  count             = "${length(var.data_subnets_cidr)}"
  vpc_id            = "${aws_vpc.web-vpc.id}"
  cidr_block        = "${element(var.data_subnets_cidr,count.index)}"
#  map_public_ip_on_launch = "true"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Data-Subnet-${count.index+1}"
    tier = "data"
  }
}

#Code to create Internet Gateway 
resource "aws_internet_gateway" "web_igw" {
  vpc_id = "${aws_vpc.web-vpc.id}"
  tags = {
    Name = "main"
  }
}

#To create public route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.web-vpc.id}"
  tags = {
    Name = "public_route_table_main"
  }
}

# Add Public Internet gateway to the route table
resource "aws_route" "public" {
  gateway_id             = "${aws_internet_gateway.web_igw.id}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_route_table.public.id}"
}

#Associate Public route table as main route table
resource "aws_main_route_table_association" "public" {
  vpc_id         = "${aws_vpc.web-vpc.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Associate Public route table with each public subnet
resource "aws_route_table_association" "public" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# create elastic IP (EIP) to assign it the NAT Gateway
resource "aws_eip" "web_eip" {
  count      = "${length(var.azs)}"
  vpc        = true
  depends_on = ["aws_internet_gateway.web_igw"]
}

# create NAT Gateways
# make sure to create the nat in a internet-facing subnet (public subnet)
resource "aws_nat_gateway" "web-nat" {
    count         = "${length(var.azs)}"
    allocation_id = "${element(aws_eip.web_eip.*.id, count.index)}"
    subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
    depends_on    = ["aws_internet_gateway.web_igw"]
}

#To Create Private route table's
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.web-vpc.id}"
  count  = "${length(var.azs)}" 
  tags = { 
    Name = "private_subnet_route_table_${count.index}"
  }
}

# Add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway_route" {
  count                  = "${length(var.azs)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = ["aws_route_table.private"]
  nat_gateway_id         = "${element(aws_nat_gateway.web-nat.*.id, count.index)}"
}

# Associate Private route table with each web subnet
resource "aws_route_table_association" "web" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.web.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Associate Private route table with each app subnet
resource "aws_route_table_association" "app" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.app.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Associate Private route table with each data subnet
resource "aws_route_table_association" "data" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.data.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_db_subnet_group" "rds_sub_group" {
  name       = "rds-sub-group"
  subnet_ids = "${data.aws_subnet_ids.data.ids}"
}

#To create Application Load Balancer Security Group to allow 80 an 443 TCP Traffic
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "allow incoming 80 and 443 TCP traffic only"
  vpc_id      = "${aws_vpc.web-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"] # We have allowed all subnet but In Production we need to specify Web-server Subnet.
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-security-group"
  }
}

#To create Internal Load Balancer Security Group to allow TCP Traffic from web_sg
resource "aws_security_group" "ilb_sg" {
  depends_on   = ["aws_security_group.web_sg"]
  name         = "ilb_sg"
  description  = "allow incoming traffic from web_sg only"
  vpc_id       = "${aws_vpc.web-vpc.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ilb-security-group"
  }
}

# security group for Web-server EC2 instances which allow 80 and 22 TCP Traffic 
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "allow incoming HTTP and SSH traffic only"
  vpc_id      = "${aws_vpc.web-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]  # We have allowed all subnet but In Production we need to specify ALB IP or specific Priavte IP range from where we will access website.
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]  # We have allowed all subnet but In Production we need to specify Jump server IP or specific Priavte IP range from where we will access servers. 
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-security-group"
  }
}

# security group for app-server EC2 instances which allow TCP Traffic only from internal LB
resource "aws_security_group" "app_sg" {
  depends_on  = ["aws_security_group.ilb_sg"]
  name        = "app_sg"
  description = "allow incoming traffic only from Internal LB and ssh traffic from Jump server or Corporate CIDR"
  vpc_id      = "${aws_vpc.web-vpc.id}"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]  # We have allowed all subnet but In Production we need to specify Jump server IP or specific Priavte IP range from where we will access servers.
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app-security-group"
  }
}

# security group for data-server EC2 instances which allow TCP Traffic only from app_sg
resource "aws_security_group" "data_sg" {
  depends_on  = ["aws_security_group.app_sg"]
  name        = "data_sg"
  description = "allow incoming traffic only from app_sg"
  vpc_id      = "${aws_vpc.web-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]   #need to provide App_server CIDR Block 
  }

  tags = {
    Name = "data-security-group"
  }
}

#RDS Passowrd Setting 

resource "random_string" "rds_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "vault_rds_password" {
  name  = "vault_rds_password"
  type  = "SecureString"
  value = "${random_string.rds_password.result}"
}

resource "aws_db_instance" "rds_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = "dbadmin"
  password               = "${random_string.rds_password.result}"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = "${aws_db_subnet_group.rds_sub_group.id}"
  multi_az               = true
  vpc_security_group_ids = ["${aws_security_group.data_sg.id}"]
}
