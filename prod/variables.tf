variable "resource_group_name" {
  default = "rg-demo"
  validation {
    condition     = can(regex("^rg-", var.resource_group_name))
    error_message = "The resource_group_name must start with 'rg-'."
  }
}
