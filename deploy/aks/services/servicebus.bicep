@secure()
param kubeConfig string
param kubernetesNamespace string
param serviceBusNamespace string
param location string
param principalId string

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
}

resource servicebus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespace
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}

resource serviceBusDataOwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '090c5cfd-751d-490a-894a-3ce6f1109419' // GUID for service bus data owner.
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, 'servicebus_role')
  properties: {
    roleDefinitionId: serviceBusDataOwnerRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


var serviceBusEndpoint = '${servicebus.id}/AuthorizationRules/RootManageSharedAccessKey'
var connectionString = listKeys(serviceBusEndpoint, servicebus.apiVersion).primaryConnectionString

resource daprIoComponent_longhaulSbRapid 'dapr.io/Component@v1alpha1' = {
  metadata: {
    name: 'longhaul-sb-rapid'
    namespace: kubernetesNamespace
  }
  spec: {
    type: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        value: connectionString
      }
    ]
  }
}

resource daprIoComponent_longhaulSbMedium 'dapr.io/Component@v1alpha1' = {
  metadata: {
    name: 'longhaul-sb-medium'
    namespace: kubernetesNamespace
  }
  spec: {
    type: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        value: connectionString
      }
    ]
  }
}

resource daprIoComponent_longhaulSbSlow 'dapr.io/Component@v1alpha1' = {
  metadata: {
    name: 'longhaul-sb-slow'
    namespace: kubernetesNamespace
  }
  spec: {
    type: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        value: connectionString
      }
    ]
  }
}

resource daprIoComponent_longhaulSbGlacial 'dapr.io/Component@v1alpha1' = {
  metadata: {
    name: 'longhaul-sb-glacial'
    namespace: kubernetesNamespace
  }
  spec: {
    type: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        value: connectionString
      }
    ]
  }
}

output servicebusNamespace string = serviceBusNamespace
