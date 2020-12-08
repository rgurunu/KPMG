# Secure-WebSite-Terraform
Deploy 3 tier Highly Available Scalable Secure website using Terraform module on AWS Cloud Platform


# What is this repository for?
This is an example of Terraform project which deploys a Secure web application using AWS infrastructure that is:

    • Isolated in a VPC
    • Load balanced
    • Auto scaled
    • Secured by SSL
    • DNS routed with Route53
    • Restricted to traffic from a list of allowed IP addresse
    • NAT Gateway  
    • Accessible by SSH 
    • Terraform Custom Module
    • RDS with Multi-Az


# How do I get set up?
This project assumes that you are already familiar with AWS and Terraform.

There are several dependencies that are needed before the Terraform project can be run. Make sure that you have:

• The Terraform binary installed and available on the PATH.
• The Access Key ID and Secret Access Key of an AWS IAM user that has programmatic access enabled.
• A Hosted Zone in AWS Route 53 for the desired domain name of the application.
• The certificate ARN of an AWS Certificate Manager SSL certificate for the domain name.
• An OpenSSH key pair that will be used to control login access to EC2 instances.

# Access credentials 

AWS access credentials must be supplied on the command line. This Terraform script was tested in my own AWS account with a user that has the AmazonEC2FullAccess and AmazonVPCFullAccess policies. It was also tested in the AWS account with a user that has the AdministratorAccess policy.

# Files
1. provider.tf :- AWS Provider.
2. main.tf :- Used to call custom modules we created and keep it in ./modules directory.
3. install.sh :- Contain Shell Script to install HTTPD service
4. variables.tf:- Used by main.tf to fetch variable's sets in the file.
5. outputs.tf :- It will print LB DNS name Once your code runs successfully
5. ./modules/networking/main.tf :- Contains code to deploy VPC/subnet's(Public/Private),Elastic IP's,Internet Gateway,Security Group's,NAT Gateway,Route Table's, RDS Instance
6. ./modules/networking/variable.tf :- Used by main.tf to fetch variable's sets in the file.
7. ./modules/networking/outputs.tf:- It will hold subnet ids and security group ids which will use by auto scaling module.
8. ./modules/autoscaling/main.tf :- Contains code to deploy AutoScaling Group with Launch Template, Application Load Balancer, ALB Target Group, ALB Target Group Listeners, ASG Scale up and Down Policy, Create A record in route 53.
9. ./modules/autoscaling/variables.tf :- Used by main.tf to fetch variable's sets in the file.
10. ./modules/autoscaling/outputs.tf :- It will hold LB DNS name.

# Deployment

1. First you have to create a key pair that will be assigned to our instances. I have used name as "mykey" by passing command : "ssh-keygen -f mykey" in same 
   directory where all the files are placed.
2. Create SSL/TLS Public certificate or if you have a private certificate you can import it to AWS Certificate Manager and create a certificate. Once certificate is created successfully please copy AWS ARN of certificate and update in variables file with Domain Name and AWS ARN which is present in ./module/autoscaling
3. terraform get  :- Download and update modules mentioned in the root module (main.tf from root directory). 
4. terraform init :- To setup provisioner
5. terraform plan :- It will show the planning of resources. 
6. terraform apply :- It will provision the services mentioned in the AWS account.
7. terraform destroy : - It will destroy all the resources which are provisioned by terraform.

If the deployment is successful you should now be able to see the infrastructure created in the AWS web console. After a delay while the web instances are 
initialised you should be able to launch the sample web application at https://terraform.[your-domain.com].

