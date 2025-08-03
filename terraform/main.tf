
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "apim_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "apim_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.apim_rg.name
  virtual_network_name = azurerm_virtual_network.apim_vnet.name
  address_prefixes     = var.subnet_address_prefixes
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.ApiManagement/service"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name
  sku_capacity        = var.sku_capacity

  virtual_network_type = "External"
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_api_management_logger" "apim_logger" {
  name                = "apim-logger"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  resource_id         = azurerm_application_insights.apim_ai.id
  logger_type         = "applicationinsights"
  credentials = {
    instrumentationKey = azurerm_application_insights.apim_ai.instrumentation_key
  }
}

resource "azurerm_application_insights" "apim_ai" {
  name                = "${var.apim_name}-ai"
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
  application_type    = "web"
}

resource "azurerm_api_management_api" "sample_api" {
  name                = "sample-api"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Sample API"
  path                = "sample"
  protocols           = ["https"]
  import {
    content_format = "swagger-link-json"
    content_value  = var.api_swagger_url
  }
}

resource "azurerm_api_management_api_operation" "sample_get" {
  operation_id        = "get-sample"
  api_name            = azurerm_api_management_api.sample_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
  display_name        = "Get Sample"
  method              = "GET"
  url_template        = "/items"
  response {
    status = 200
    description = "Successful response"
  }
}

resource "azurerm_api_management_user" "apim_user" {
  user_id             = "sampleuser"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  email               = var.user_email
  first_name          = "Sample"
  last_name           = "User"
  state               = "active"
}

resource "azurerm_api_management_diagnostic" "apim_diag" {
  identifier          = "applicationinsights"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  api_name            = azurerm_api_management_api.sample_api.name
  logger_id           = azurerm_api_management_logger.apim_logger.id
  sampling {
    percentage = 100
  }
  frontend_request {
    headers = ["*"]
    body    = {
      bytes = 512
    }
  }
  frontend_response {
    headers = ["*"]
    body    = {
      bytes = 512
    }
  }
  backend_request {
    headers = ["*"]
    body    = {
      bytes = 512
    }
  }
  backend_response {
    headers = ["*"]
    body    = {
      bytes = 512
    }
  }
}

output "apim_hostname" {
  value = azurerm_api_management.apim.gateway_url
}
