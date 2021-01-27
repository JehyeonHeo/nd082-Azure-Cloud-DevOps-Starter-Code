variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "AzureWebServerDeploy"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "koreacentral"
}

variable "minimum-number-of-vm" {
  description = "Set minimum number of virtual machines to deploy"
  default = 2
}

variable "username" {
    description = "Set username for virtual machines"
    default = "AzureWebServerDeployUser"
}

variable "password" {
    description = "Set password for virtual machines"
    default = "thisispassword123$"
}