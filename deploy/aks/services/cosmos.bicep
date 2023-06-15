
param cosmosAccountName string
param cosmosDatabaseName string = 'longhauldb'
param cosmosContainerName string = 'longhaulcontainer'
param location string
param principalId string
param roleDefinitionName string = 'dataRole'
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosAccountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  parent: cosmosAccount
  name: cosmosDatabaseName
  properties: {
    resource: {
      id: cosmosDatabaseName
    }
  }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
  parent: cosmosDatabase
  name: cosmosContainerName
  properties: {
    resource: {
      id: cosmosContainerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
  }
}

resource cosmosDataOwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // GUID for Contributor.
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, 'cosmos_role')
  properties: {
    roleDefinitionId: cosmosDataOwnerRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

var roleDefinitionId = guid('sql-role-definition-', principalId, cosmosAccount.id)
var roleAssignmentId = guid(roleDefinitionId, principalId, cosmosAccount.id)

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  name: roleDefinitionId
  parent: cosmosAccount
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      cosmosAccount.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: roleAssignmentId
  parent: cosmosAccount
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: principalId
    scope: cosmosAccount.id
  }
}

output cosmosUrl string = cosmosAccount.properties.documentEndpoint
output cosmosAccountName string = cosmosAccountName
output cosmosDatabaseName string = 'longhauldb'
output cosmosContainerName string = 'longhaulcontainer'
