param webAppName string
param appServicePlanName string
param storageAccountName string
param location string = resourceGroup().location
param shareName string
param dockerServerUrl string
param dockerServerUsername string
param dockerServerPassword string
param dbFileUrl string
param websiteEnableAppStoragePath string
param configMountPath string
param dbMountPath string
param linuxFxVersion string
param netFrameworkVersion string
param virtualPath string
param physicalPath string

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource appServicePlanName_resource 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccountName_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: storageAccountName_resource
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccountName_default 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  parent: storageAccountName_resource
  name: 'default'
  properties: {
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccountName_default 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  parent: storageAccountName_resource
  name: 'default'
  properties: {
  }
}

resource webAppName_resource 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppName
  location: location
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanName_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      appSettings:[             
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerServerUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerServerUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerServerPassword
        }
        {
          name: 'GF_DATABASE_URL'
          value: dbFileUrl
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: websiteEnableAppStoragePath
        }        
      ]
      numberOfWorkers: 1
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}


resource webAppName_web 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: webAppName_resource
  name: 'web'
  location: location
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
    ]
    netFrameworkVersion: netFrameworkVersion
    linuxFxVersion: linuxFxVersion
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${webAppName}'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: virtualPath
        physicalPath: physicalPath
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'AllAllowed'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {
      'config': {
        type: 'AzureFiles'
        accountName: storageAccountName
        shareName: shareName
        mountPath: configMountPath
        accessKey: listKeys(storageAccountName_resource.id, storageAccountName_resource.apiVersion).keys[0].value
      }
      'grafana': {
        type: 'AzureFiles'
        accountName: storageAccountName
        shareName: shareName
        mountPath: dbMountPath
        accessKey: listKeys(storageAccountName_resource.id, storageAccountName_resource.apiVersion).keys[0].value
      }
    }
  }
}

resource webAppName_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2021-01-15' = {
  parent: webAppName_resource
  name: '${webAppName}.azurewebsites.net'
  location: location
  properties: {
    siteName: webAppName
    hostNameType: 'Verified'
  }
}

resource storageAccountName_default_ams_grafana 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccountName_default
  name: shareName
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccountName_resource
  ]
}
