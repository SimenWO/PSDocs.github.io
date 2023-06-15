# Vnet

This documentation is automatically generated and should not be updated manually.

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
vnetName       | Yes      |
location       | No       |
addressPrefix  | No       |
subnetPrefix   | No       |
subnetName     | No       |

### vnetName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)



### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)



- Default value: `[resourceGroup().location]`

### addressPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)



- Default value: `10.0.0.0/16`

### subnetPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)



- Default value: `10.0.0.0/24`

### subnetName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)



- Default value: `default`

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "infrastructure/vnet/main.json"
    },
    "parameters": {
        "vnetName": {
            "value": ""
        },
        "location": {
            "value": "[resourceGroup().location]"
        },
        "addressPrefix": {
            "value": "10.0.0.0/16"
        },
        "subnetPrefix": {
            "value": "10.0.0.0/24"
        },
        "subnetName": {
            "value": "default"
        }
    }
}
```


