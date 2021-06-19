resource "azurerm_monitor_action_group" "jdtest" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.jdtest.name
  short_name          = "p0action"

  arm_role_receiver {
    name                    = "armroleaction"
    role_id                 = "de139f84-1756-47ae-9be6-808fbbe84772"
    use_common_alert_schema = true
  }

/*
  automation_runbook_receiver {
    name                    = "action_name_1"
    automation_account_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-runbooks/providers/microsoft.automation/automationaccounts/aaa001"
    runbook_name            = "my runbook"
    webhook_resource_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-runbooks/providers/microsoft.automation/automationaccounts/aaa001/webhooks/webhook_alert"
    is_global_runbook       = true
    service_uri             = "https://s13events.azure-automation.net/webhooks?token=randomtoken"
    use_common_alert_schema = true
  }
*/

  azure_app_push_receiver {
    name          = "pushtoadmin"
    email_address = "joseph.duarte@otis.com"
  }

  /*
  azure_function_receiver {
    name                     = "funcaction"
    function_app_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-funcapp/providers/Microsoft.Web/sites/funcapp"
    function_name            = "myfunc"
    http_trigger_url         = "https://jdtest.com/trigger"
    use_common_alert_schema  = true
  }
*/
  email_receiver {
    name          = "sendtoadmin"
    email_address = "joseph.duarte@otis.com"
  }

  email_receiver {
    name                    = "sendtodevops"
    email_address           = "joseph.duarte@otis.com"
    use_common_alert_schema = true
  }

/*
  itsm_receiver {
    name                 = "createorupdateticket"
    workspace_id         = "6eee3a18-aac3-40e4-b98e-1f309f329816"
    connection_id        = "53de6956-42b4-41ba-be3c-b154cdf17b13"
    ticket_configuration = "{}"
    region               = "southcentralus"
  }

  logic_app_receiver {
    name                    = "logicappaction"
    resource_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-logicapp/providers/Microsoft.Logic/workflows/logicapp"
    callback_url            = "https://logicapptriggerurl/..."
    use_common_alert_schema = true
  }

  sms_receiver {
    name         = "oncallmsg"
    country_code = "1"
    phone_number = "1231231234"
  }

  voice_receiver {
    name         = "remotesupport"
    country_code = "86"
    phone_number = "13888888888"
  }

  webhook_receiver {
    name                    = "callmyapiaswell"
    service_uri             = "http://jdtest.com/alert"
    use_common_alert_schema = true
  }
}
*/