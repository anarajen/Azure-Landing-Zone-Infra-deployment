variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workspace_resource_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.workspace_resource_id
      name                  = "law"
    }
  }

  data_flow {
    streams = [
      "Microsoft-Perf",
      "Microsoft-Event"
    ]

    destinations = ["law"]
  }

  data_sources {
    performance_counter {
      name                          = "windows-perf"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
    }

    windows_event_log {
      name    = "windows-events"
      streams = ["Microsoft-Event"]

      x_path_queries = [
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
  }
}

output "id" {
  value = azurerm_monitor_data_collection_rule.this.id
}