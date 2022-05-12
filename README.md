[![Build Status](https://dev.azure.com/radixsolutions/VM%20Pipeline/_apis/build/status/gjlabus.VMPipeline?branchName=main)](https://dev.azure.com/radixsolutions/VM%20Pipeline/_build/latest?definitionId=3&branchName=main)

# AzDo-Bicep

# VM Image-Builder

This module creates the customized os image according to CIS benchmark approved by security.

## **TABLE OF CONTENTS**

- [VM Image Builder](#vm-image-builder)
  - [**TABLE OF CONTENTS**](#table-of-contents)
  - [General Information](#general-information)
  - [Nested Modules](#nested-modules)
  - [Resource Types](#resource-types)
  - [Parameters](#parameters)
  - [Important Information](#important-information)
  - [Example pipeline](#example-pipeline)
  - [Outputs](#outputs)
  - [Template references](#template-references)
  - [Additional resources](#additional-resources)

## General Information

This module creates a CIS Hardened os image which can be used to provision virtual machines.
Currently below 4 versions have been tested with CIS Hardening.

- RHEL-LVM 7.9
- RHEL-LVM 8.x
- Windows Server 2019
- Windows Server 2016

Information on how to use a shared module in general can be found here: [How to use shared modules](https://github.com/RoyalAholdDelhaize/ah-tech-shared-repositories-skeleton)

## Nested Modules

This repository is making use of the following nested modules and bicep registry. So please check the readme of the nested modules what to do.

| Shared Module                         | Github/Acr                                                                                    |
| :--------------------------------     | :-------------------------------------------------------------------------------------------- |
| ah-tech-shared-storageaccount         | acrsharedweeu01.azurecr.io/bicep/modules/ah-tech-shared-storageaccount:1.0.1                  |
| ah-tech-shared-resource-group         | acrsharedweeu01.azurecr.io/bicep/modules/ah-tech-shared-resource-group:2.0.1                  |
| ah-tech-shared-managed-identity       | acrsharedweeu01.azurecr.io/bicep/modules/ah-tech-shared-managed-identity:1.0.0                |
| ah-tech-shared-network-security-group | acrsharedweeu01.azurecr.io/bicep/modules/ah-tech-shared-network-security-group:2.0.1          |
| ah-tech-shared-subnet                 | acrsharedweeu01.azurecr.io/bicep/modules/ah-tech-shared-subnet:1.0.0                          |

## Resource Types

| Resource Type                                                                          | Api Version         |
| :------------------------------------------------------------------------------------- | :------------------ |
| `Microsoft.Resources/resourceGroups`                                                   | 2021-04-01          |
| `Microsoft.Storage/storageAccounts`                                                    | 2021-04-01          |
| `Microsoft.Authorization/roleAssignments`                                              | 2021-04-01-preview  |
| `Microsoft.Compute/galleries`                                                          | 2019-12-01          |
| `Microsoft.Compute/galleries/images`                                                   | 2019-12-01          |
| `Microsoft.Storage/storageAccounts/blobServices/containers/providers/roleAssignments`  | 2020-04-01-preview  |
| `Microsoft.VirtualMachineImages/imageTemplates`                                        | 2020-02-14          |
| `Microsoft.ManagedIdentity/userAssignedIdentities`                                     | 2018-11-30          |
| `Microsoft.Network/networkSecurityGroups`                                              | 2021-03-01          |
| `Microsoft.Network/virtualNetworks/subnets`                                            | 2021-03-01          |


## Parameters

| Parameter Name            | Type    | Default Value                | Possible Values                      | Description                                                                                                         |
| :------------------------ | :------ | :--------------------------- | :----------------------------------- | :------------------------------------------------------------------------------------------------------------------ |
| `location`                | string  |                              |                                      | Required. Location of resource group where the image gallery will be located.                                       |
| `resourceGroupName `      | string  |                              |                                      | Required. Specify the Resource Group Name                                                                           |
| `subscriptionId`          | string  |                              |                                      | Required. Specify the Subscription Id of RSG.                                                                       |
| `serviceConnection`       | string  |                              |                                      | Required. Specify the Az devops Service Connection to use.                                                          |
| `storageAccountName`      | string  |                              |                                      | Required. Specify the Storage account name.                                                                         |
| `storagecontainer`        | string  |                              |                                      | Required. Specify container name to create inside storage account.                                                  |
| `userAssignedIdentity`    | string  |                              |                                      | Required. Specify managed identity.                                                                                 |
| `nsgName`                 | string  |                              |                                      | Required. Specify the Network security group name.                                                                  |
| `subnetName`              | string  |                              |                                      | Required. Specify the subnet name.                                                                                  |
| `subnetAddressPrefix `    | string  |                              |                                      | Required. Specify the subnet prefix                                                                                 |
| `vnetName`                | string  |                              |                                      | Required. Specify the virtual network name                                                                          |
| `resourceGroupNameVnet`   | string  |                              |                                      | Required. Specify the Resource group name for vnet.                                                                 |
| `shdImageGalleryName`     | string  |                              |                                      | Required. Specify the Shared image gallery name.                                                                    |
| `shdImageName`            | string  |                              |                                      | Required. Specify the Shared image name to create.                                                                  |
| `shdImageVersion`         | string  |                              |                                      | Required. Specify the Shared image version.                                                                         |
| `shdImagePublisher`       | string  | `AHIT`                       |                                      | Optional. Specify the Shared image publisher.                                                                       |
| `mpImagePublisher`        | string  |                              |                                      | Required. Specify the Marketplace image publisher. See [Marketplace URN](#marketplace-urn)                           |
| `mpImageOffer`            | string  |                              |                                      | Required. Specify the Marketplace image offer. See [Marketplace URN](#marketplace-urn)                               |
| `mpImageSku`              | string  |                              |                                      | Required. Specify the Marketplace image sku. See [Marketplace URN](#marketplace-urn)                                 |
| `mpImageVersion `         | string  |                              |                                      | Required. Specify the Marketplace image version. See [Marketplace URN](#marketplace-urn)                             |
| `imageOsType`             | string  |                              |                                      | Required. Specify the OS Type.                                                                                      |
| `vmSize`                  | string  | `Standard_D4s_v4`            |                                      | Optional. Specify the VM Size to use to build image.                                                                |
| `tags`                  | string  |            |                                      | Optional. Specify a Json hashtable of tags to add to the resource groups.       |
## Marketplace URN
Make sure you provide the correct value for image specific parameters by checking from marketplace. You can get the exact value using az cli command.
```
az vm image list --offer rhel -l westeurope --all -s 8-lvm --output table

Offer    Publisher    Sku         Urn                                    Version
-------  -----------  ----------  -------------------------------------  --------------
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.0.20210422         8.0.20210422
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.1.20200318         8.1.20200318
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.1.20200901         8.1.20200901
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.1.2021040401       8.1.2021040401
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.2.20200509         8.2.20200509
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.2.20200905         8.2.20200905
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.2.2021040401       8.2.2021040401
RHEL     RedHat       8-LVM       RedHat:RHEL:8-LVM:8.3.2020111909       8.3.2020111909

```

## Important Information:

- To build the image , make sure that the SUBNET has atleast 4 IP available. Without this, the image creation process will fail. This is beacuse the module creates the local n/w which needs 1 IP for proxy VM , 1 IP for actual VM , 1 IP for loadbalancer and 1 IP for private endpoint.
- Checkout of an additional repository `ah-tech-shared-azure-deploy` in your pipeline is a must for this module to work. See [Example Pipeline](#example-pipeline)
- If the module/pipeline fails due to any reason (see the error below), the logs of the imagebuilder are stored in a temporary rsg that is created during the image building process by microsoft with name starting with prefix IT_<RSG_NAME>_<IMAGE_TEMPLATE_NAME>*  . You need to go to this rsg and check the storage account for the packerlogs to analyze further.
```
Please check the image builder logs from storage account under resource group IT_<RSG_NAME>_<IMAGE_TEMPLATE_NAME>* for the status.
/home/vsts/work/1/s/ah-tech-shared-image-builder/scripts/Invoke-AzImageBuilder.ps1 : Image Build Status : Failed
Check the logs stored in the storage blob for more details.
At /home/vsts/work/_temp/azureclitaskscript1640094412170.ps1:3 char:1
+ . '/home/vsts/work/1/s/ah-tech-shared-image-builder/scripts/Invoke-Az …
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
+ FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Invoke-AzImageBuilder.ps1

```
- There might be situation where in you see below error in your pipeiline
```
##[error]The job running on agent Hosted Agent ran longer than the maximum time of 60 minutes. For more information, see https://go.microsoft.com/fwlink/?linkid=2077134
```
  This can cause due to : \
  VM Size  ( default Standard_D4s_v4) for image build process. Consider changing the value of parameter `vmSize` to a more powerful machine size.

  TimeOut setting in the JOB. By default, the timeout for a JOB is 60 mins. Consider increasing this time to 120 mins.

- Sometime, the image building process is stuck and eventually gets timedout.Especially for windows, one reason could be the an incompatiable windows update. Check the logs and try to exclude that update using your own customization file. See below eg.
```
            {
                "type": "WindowsUpdate",
                "searchCriteria": "BrowseOnly=0 and IsInstalled=0",
                "filters": [
                    "exclude:$_.Title -like '*Preview*'",
                    "exclude:$_.Title -like '*KB2267602*'",
                    "include:$true"
                ],
                "updateLimit": 40
            }
```

## Example pipeline:

Below is an example of user's pipeline that is utilizing image builder module.

```yml
trigger: none
pr: none

pool:
  vmImage: 'ubuntu-latest'

variables:
  resourceGroupName: 'WeEu-xx-xxx-xxx'
  location: 'westeurope'
  subscriptionId: 'aaaa-bbbb-cccc-dd-eee'
  serviceConnection: 'sub-ahtech-nonprd-xxxx'
  storageAccountName: 'weeusanamexxxx'
  storageContainer: 'artifacts'
  userAssignedIdentity: 'mi-aib-xxxx'
  nsgName: 'nsg-xxxxx'
  vnetName: 'vnet-xxxx'
  subnetName: 'snt-xxxx'
  subnetAddressPrefix: '10.xx.xx.xx/28'
  resourceGroupNameVnet: 'rg-xxxx'
  shdImageGalleryName: 'shdxxxx'
  vmSize: 'Standard_D4s_v4'
  shdImagePublisher: 'AHIT'
#  shdImageName: 'rhel-8.4-cis'
#  shdImageVersion: '2021.12.20' //For reference only, can be any value
#  mpImagePublisher: 'RedHat'
#  mpImageOffer: 'RHEL'
#  mpImageSku: '8-LVM'
#  mpImageVersion: '8.4.2021091103'
#  imageOsType: 'Linux'
  shdImageName: 'msws-2019-cis'
  shdImageVersion: '2021.12.21'
  mpImagePublisher: 'MicrosoftWindowsServer'
  mpImageOffer: 'WindowsServer'
  mpImageSku: '2019-Datacenter'
  mpImageVersion: 'latest'
  imageOsType: 'Windows'
  tags: '{"tag1":"test", .... ,"tag5":"test"}'

resources:
  repositories:
    - repository: ah-tech-shared-image-builder
      name: RoyalAholdDelhaize/ah-tech-shared-image-builder
      endpoint: RoyalAholdDelhaize
      type: github

stages:
################################################################
# Deploy Aib
################################################################
  - stage: DeployAib
    dependsOn: []
    displayName: Deploy AIB
    jobs:
      - job: AzureAIB
	timeoutInMinutes: 240
	displayName: Deploy AIB
	steps:
	  - template: pipelines/steps.pipeline.yml@ah-tech-shared-image-builder
	    parameters:
	      subscriptionId: ${{ variables.subscriptionId }}
	      serviceConnection: ${{ variables.serviceConnection }}
	      location: ${{ variables.location }}
	      resourceGroupName: ${{ variables.resourceGroupName }}
	      storageAccountName: ${{ variables.storageAccountName }}
	      storageContainer: ${{ variables.storageContainer }}
	      userAssignedIdentity: ${{ variables.userAssignedIdentity }}
	      nsgName: ${{ variables.nsgName }}
	      subnetName: ${{ variables.subnetName }}
	      subnetAddressPrefix: ${{ variables.subnetAddressPrefix }}
	      vnetName: ${{ variables.vnetName }}
	      resourceGroupNameVnet: ${{ variables.resourceGroupNameVnet }}
	      shdImageGalleryName: ${{ variables.shdImageGalleryName }}
	      shdImageName: ${{ variables.shdImageName }}
	      shdImageVersion: ${{ variables.shdImageVersion }}
	      shdImagePublisher: ${{ variables.shdImagePublisher }}
	      mpImagePublisher: ${{ variables.mpImagePublisher }}
	      mpImageOffer: ${{ variables.mpImageOffer }}
	      mpImageSku: ${{ variables.mpImageSku }}
	      mpImageVersion: ${{ variables.mpImageVersion }}
	      imageOsType: ${{ variables.imageOsType }}
	      vmSize: ${{ variables.vmSize }}

```

## Outputs

None


## Template references

- [Resourcegroups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Resources/2021-04-01/resourceGroups)
- [Storageaccounts](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-04-01/storageAccounts)
- [Role Assignments](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/2020-04-01-preview/roleassignments)
- [Galleries](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-12-01/galleries)
- [Images](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-12-01/galleries/images)
- [Image Templates](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json)
- [Managed Identity](https://docs.microsoft.com/en-us/azure/templates/microsoft.managedidentity/2018-11-30/userassignedidentities)
- [Network Security Group](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2021-03-01/networksecuritygroups)
- [Subnet](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2021-03-01/virtualnetworks/subnets)

## Additional resources

- [What is Azure Image Builder?](https://docs.microsoft.com/en-us/azure/virtual-machines/image-builder-overview)
- [Microsoft.VirtualMachineImages/imageTemplates template reference](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-json)
- [Virtual Machine / Image Builder](https://confluence-aholddelhaize.atlassian.net/wiki/spaces/TEP/pages/98322263156/Virtual+Machine)
