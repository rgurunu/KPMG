#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo chkconfig httpd on
sudo service httpd start
echo "<h1>Deployed via Terraform wih ALB</h1>" | sudo tee /var/www/html/index.html
root@e594ba0d7b1c:/home/cloud_user/kpmg# cat main.tf 
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykey1"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
  lifecycle {
    ignore_changes = [public_key]
  }
}

module "autoscaling" {
  source                = "./modules/autoscaling"
  namespace             = var.namespace
  ssh_keypair           = aws_key_pair.mykeypair.key_name
 
  vpc                   = module.networking.vpc
  subnet_public         = tolist(module.networking.subnet-pub)
  subnet_web            = tolist(module.networking.subnet-web)
  subnet_app            = tolist(module.networking.subnet-app)
  subnet_data           = tolist(module.networking.subnet-data)
  sg                    = module.networking.sg
}
 
module "networking" {
  source    = "./modules/networking"
}
