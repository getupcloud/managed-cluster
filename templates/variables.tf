variable "cronitor_api_key" {
  description = "Cronitor API key"
  type        = string
  default     = ""
}

variable "opsgenie_api_key" {
  description = "Opsgenie API key to create prometheus integration"
  type        = string
  default     = ""
}
