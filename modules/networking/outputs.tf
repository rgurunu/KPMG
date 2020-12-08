output "vpc" {
  value = "${aws_vpc.web-vpc}"
}

output "subnet-pub" {
  value = "${data.aws_subnet_ids.public.ids}"
}

output "subnet-web" {
  value = "${data.aws_subnet_ids.web.ids}"
}

output "subnet-app" {
  value = "${data.aws_subnet_ids.app.ids}"
}

output "subnet-data" {
  value = "${data.aws_subnet_ids.data.ids}"
}

output "rds_password" {
  value = "${aws_ssm_parameter.vault_rds_password.value}"
}

output "rds_subnet_group" {
  value = "${data.aws_subnet_ids.data.ids}"
}

output "sg" {
  value = {
    lb       = "${aws_security_group.alb_sg.id}"
    ilb      = "${aws_security_group.ilb_sg.id}"
    websvr   = "${aws_security_group.web_sg.id}"
    appsvr   = "${aws_security_group.app_sg.id}"
    datasvr  = "${aws_security_group.data_sg.id}"
  }
}
