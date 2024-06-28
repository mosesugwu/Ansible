variable "client_id" {
  description = "(Optional) This Client ID which should be used. This can also be sourced from ARM_CLIENT_ID Environment Variable."
  type        = string
  default     = "49d663e0-c997-439d-b75f-bac184c474d8"
}

variable "subscription_id" {
  description = "(Optional) This Subscription ID which should be used. This can also be sourced from ARM_CLIENT_ID Environment Variable."
  type        = string
  default     = "3e58bbdc-9887-4d0f-af48-e47b110f81a5"

}

variable "tenant_id" {
  description = "(Optional) This Tenant ID which should be used. This can also be sourced from ARM_CLIENT_ID Environment Variable."
  type        = string
  default     = "062b4bc0-fa03-4ff6-898f-318d88f23127"

}

variable "client_secret" {
  description = "(Optional) This Client Secret which should be used. This can also be sourced from ARM_CLIENT_ID Environment Variable."
  type        = string

}

variable "nsg_name" {
  description = " (Required) The name of the security rule. This needs to be unique across all Rules in the Network Security Group. Changing this forces a new resource to be created."
  type        = string
  default     = ""


}

# variable "virtual_machines" {
#   description = "Virtual Machines to be deployed"
#   type        = map(object({}))
#   default     = {}

# }