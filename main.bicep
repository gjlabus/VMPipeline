param resourcePrefix string
param virtualNetworkPrefix string
param location string
param currentDate string = utcNow('yyyy-MM-dd')

var subnetname = '${resourcePrefix}-sn'
var tagValues = {
  CreatedBy: 'BICEPDeployment'
  deploymentDate: currentDate
}

module sta 'Modules/storageAccount.bicep' = {
  name: 'sta'
  params: {
    storageAccountPrefix: resourcePrefix
    tagValues: tagValues
    location: location
  }
}

module nsg 'Modules/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    ResourcePrefix: resourcePrefix
    tagValues: tagValues
    securityRules: []
    location: location
  }
}

module vnet 'Modules/virtualNetwork.bicep' = {
  name: 'vnet'
  params: {
    ResourcePrefix: resourcePrefix
    virtualNetworkPrefix: virtualNetworkPrefix
    tagValues: tagValues
    location: location
    subnets: [
      {
        name: subnetname
        virtualNetworkPrefix: replace(virtualNetworkPrefix, '0.0/16', '1.0/24')
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
        nsg: nsg.outputs.nsgid
      }
    ]
  }
}

module privateEndPoint 'Modules/privateEndpoint.bicep' = {
  name: 'privateEndPoint'
  params: {
    tagValues: tagValues
    privateEndpointName: '${resourcePrefix}-pep'
    storageAccountId: sta.outputs.staid
    vnetId: vnet.outputs.vnetid
    subnetName: subnetname
    location: location
  }
}
