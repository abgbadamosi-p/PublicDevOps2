variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "open_api_spec_content_format" {
  description = "The format of the content from which the API Definition should be imported. Possible values are: openapi, openapi+json, openapi+json-link, openapi-link, swagger-json, swagger-link-json, wadl-link-json, wadl-xml, wsdl and wsdl-link."
}

variable "open_api_spec_content_value" {
  description = "The Content from which the API Definition should be imported. When a content_format of *-link-* is specified this must be a URL, otherwise this must be defined inline."
}


variable "bkstrgrg" {
  type        = string
  description = "The name of the backend storage account resource group"
  default     = "<storage act resource group name>"
}

variable "bkstrg" {
  type        = string
  description = "The name of the backend storage account"
  default     = "<storage account name>"
}

variable "bkcontainer" {
  type = string
  description = "The container name for the backend config"
  default = "<blob storage container name>"
}

variable "bkstrgkey" {
  type = string
  description = "The access key for the storage account"
  default = "<storage account key>"
}

variable "resourcegroup_name" {
  type        = string
  description = "The name of the resource group"
  default     = "<resource group name>"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
  default     = "<region>"
}

variable "tags" {
  type        = map(string)
  description = "Tags used for the deployment"
  default = {
    "Environment" = "Dev"
    "Owner"       = "<name>"
  }
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet"
  default     = "<vnet name>"
}

variable "vnet_address_space" {
  type        = list(any)
  description = "the address space of the VNet"
  default     = ["10.13.0.0/16"]
}

variable "subnets" {
  type = map(any)
  default = {
    subnet_1 = {
      name             = "subnet_1"
      address_prefixes = ["10.13.1.0/24"]
    }
    subnet_2 = {
      name             = "subnet_2"
      address_prefixes = ["10.13.2.0/24"]
    }
    subnet_3 = {
      name             = "subnet_3"
      address_prefixes = ["10.13.3.0/24"]
    }
    # The name must be AzureBastionSubnet
    bastion_subnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.13.250.0/24"]
    }
  }
}

}
