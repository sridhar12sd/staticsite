terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subsid
  client_id       = var.clientid
  client_secret   = var.secretid
  tenant_id       = var.tenantid
  features {}
}

resource "azurerm_resource_group" "static_webapps" {
  name     = "my-static-webapps-resource-group"
  location = "Central US"
}

resource "azurerm_template_deployment" "example" {
  name                = "acctesttemplate-01"
  resource_group_name = azurerm_resource_group.static_webapps.name

  template_body = <<DEPLOY
{
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "repositoryUrl": {
                "type": "string"
            },
            "branch": {
                "type": "string"
            },
            "repositoryToken": {
                "type": "securestring"
            }
        },
        "resources": [
            {
                "apiVersion": "2021-01-15",
                "name": "MyFirstStaticWebapps",
                "type": "Microsoft.Web/staticSites",
                "location": "Central US",
                "tags": {
                    "Environment": "Development",
                    "Project": "Testing StaticWebaaps with ARM",
                    "ApplicationName": "MyFirstStaticWebapps"
                },
                "properties": {
                    "repositoryUrl": "[parameters('repositoryUrl')]",
                    "branch": "[parameters('branch')]",
                    "repositoryToken": "[parameters('repositoryToken')]",
                    "buildProperties": {
                        "appLocation": "/",
                        "apiLocation": "",
                        "appArtifactLocation": "src"
                    }
                },
                "sku": {
                    "Tier": "Free",
                    "Name": "Free"
                },
                "resources":[
                    {
                        "apiVersion": "2021-01-15",
                        "name": "appsettings",
                        "type": "config",
                        "location": "Central US",
                        "properties": {
                            "MY_APP_SETTING1": "value 1",
                            "MY_APP_SETTING2": "value 2"
                        },
                        "dependsOn": [
                            "[resourceId('Microsoft.Web/staticSites', 'MyFirstStaticWebapps')]"
                        ]
                    }
                ]
            }
        ]
    }
DEPLOY


  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "repositoryUrl" = var.github_repo
    "branch" = var.github_branch
    "repositoryToken" = var.github_access_token
  }

  deployment_mode = "Incremental"
}

# resource "azurerm_static_site" "my-first-static-site" {
#   name                = "my-static-site2"
#   location            = azurerm_resource_group.static_webapps.location
#   resource_group_name = azurerm_resource_group.static_webapps.name
# }
