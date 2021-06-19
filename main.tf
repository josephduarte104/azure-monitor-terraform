terraform { 
  required_version = "=0.12.29"
}

provider "azurerm" {
  version = "~>2.46.0"
  features {}
}

resource "azurerm_resource_group" "jdtest" {
  name     = "monitor-jdtest-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "jdtest" {
  name                     = "storageaccountjdtest"
  resource_group_name      = azurerm_resource_group.jdtest.name
  location                 = azurerm_resource_group.jdtest.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_log_analytics_workspace" "jdtest" {
  name                = "acctest-01"
  location            = azurerm_resource_group.jdtest.location
  resource_group_name = azurerm_resource_group.jdtest.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

/*
resource "azurerm_eventhub_namespace" "jdtest" {
  name                = "logprofileeventhubjdtest"
  location            = azurerm_resource_group.jdtest.location
  resource_group_name = azurerm_resource_group.jdtest.name
  sku                 = "Standard"
  capacity            = 2
}

resource "azurerm_monitor_log_profile" "jdtest" {
  name = "logprofilejdtest"

  categories = [
    "Action",
    "Delete",
    "Write",
  ]

  locations = [
    "westus",
    "global",
  ]

  # RootManageSharedAccessKey is created by default with listen, send, manage permissions
  servicebus_rule_id = "${azurerm_eventhub_namespace.jdtest.id}/authorizationrules/RootManageSharedAccessKey"
  storage_account_id = azurerm_storage_account.jdtest.id

  retention_policy {
    enabled = true
    days    = 7
  }
}
*/


resource "azurerm_sql_server" "jdtest" {
  name                         = "jdtest-sqlserver"
  resource_group_name          = azurerm_resource_group.jdtest.name
  location                     = azurerm_resource_group.jdtest.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "jdtest" {
  name           = "acctest-db-d"
  server_id      = azurerm_sql_server.jdtest.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.jdtest.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.jdtest.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }


  tags = {
    foo = "bar"
  }

}

# CosmosDB Account

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "tfex-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.jdtest.location
  resource_group_name = azurerm_resource_group.jdtest.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 600
    max_staleness_prefix    = 120000
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  geo_location {
    location          = azurerm_resource_group.jdtest.location
    failover_priority = 0
  }
}
# CosmosDB Databases

resource "azurerm_cosmosdb_sql_database" "jdtest" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}

#SQL Diagnostics

resource "azurerm_monitor_diagnostic_setting" "jdtest" {
  name               = "jdtest"
  target_resource_id = azurerm_mssql_database.jdtest.id
  storage_account_id = azurerm_storage_account.jdtest.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.jdtest.id	

  log {
    category = "Errors"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "Basic"

    retention_policy {
      enabled = true
    }
  }
}

# CosmosDB Diagnostics

resource "azurerm_monitor_diagnostic_setting" "cosmosdb" {
  name               = "jdtest"
  target_resource_id = azurerm_cosmosdb_account.db.id
  storage_account_id = azurerm_storage_account.jdtest.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.jdtest.id	

  log {
    category = "TableApiRequests"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "Requests"

    retention_policy {
      enabled = true
    }
  }
}