# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you can use a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. **'server.json'** generates Ubuntu 18.04-LTS image using Packer. 

2. **'main.tf'** is Terraform main template, and it can make below things in Azure.
> - Resource group
> - Virtual network
> - Network security group with security rules
> - Network interface for each virtual machine(default: 2 units)
> - Public IP
> - Load Balancer
> - Virtual machine availability set
> - Virtual machines with managed disk(default: 2 units)

3. **'vars.tf'** is Terraform variables template, and it can set below variables.
> - 'prefix' for name of all resources(default: "AzureWebServerDeploy")
> - 'location' for resource group and resources(default: "koreacentral")
> - 'minimum-number-of-vm' for making minimum number of virtual machine(default: 2)
> - 'username' for virtual machine(default: "AzureWebServerDeployUser")
> - 'password' for virtual machine(default: "thisispassword123$") 

4. **'tagging-policy.rule.json'** can define policy to deny the creation of resources that do not have tags.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. How to run Packer template:
> 1.1 Check your client_id, client_secret, subscription_id first.
>
> 1.2 Make resource group for your image(default: "AzureWebServerTry").
>     If you want to use resource group with other name, revise "managed_image_resource_group_name" in server.json.
>
> 1.3 Type below command in the folder of server.json using CLI.
> > packer build server.json -var "client_id=*your_client_id*" -var "client_secret=*your_client_secret*" -var "subscription_id=*your_subscription_id*"

2. How to run Terraform templates:
> 2.1 Type below command in the folder of main.tf using CLI if you don't need to change default variables.
> > Terraform plan -out=solution.plan
>
> 2.2 If you want to specify other value for variables, refer to below example code.
> > Terraform plan -var "username=User" -out=solution.plan
>
> 2.3 If you need to set lots of variables, using variable definitions(.tfvars) file will be more convenient to you.
> > Terraform plan -var-file="variables.tfvars" -out=solution.plan
>
> > #Below code is one example of "variables.tfvars"
> > location = "eastus"
> > prefix = "AzureWebServerTest"

> 2.4 Type below command in the folder of main.tf using CLI.
> > Terraform apply "solution.plan"

> 2.5 If you want to see the made resources, type below command.
> > Terraform show

### Output
You will find below things are made in Azure. Below names in parenthesis are the result of default setting.  
> - Resource group(AzureWebServerDeploy-resources)
> - Virtual network(AzureWebServerDeploy-network)
> - Network security group(AzureWebServerDeploy-network-security-group)
> - Network interface(AzureWebServerDeploy-nic-0)
> - Network interface(AzureWebServerDeploy-nic-1)
> - Public IP(AzureWebServerDeploy-public-ip)
> - Load Balancer(TestLoadBalancer)
> - Virtual machine availability set(AzureWebServerDeploy-availability-set)
> - Virtual machine(AzureWebServerDeploy-vm-0)
> - Virtual machine managed disk(AzureWebServerDeploy-vm-0_disk1_~)
> - Virtual machine(AzureWebServerDeploy-vm-1)
> - Virtual machine managed disk(AzureWebServerDeploy-vm-1_disk1_~)

