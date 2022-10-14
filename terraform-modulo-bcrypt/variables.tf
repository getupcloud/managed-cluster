variable "keepers" {
  default = {}
  type    = map
}

variable "length" {
  default = 16
  type    = number
}

variable "lower" {
  default = true
  type    = bool
}

variable "min_lower" {
  default = 2
  type    = number
}

variable "min_numeric" {
  default = 2
  type    = number
}

variable "min_special" {
  default = 2
  type    = number
}

variable "min_upper" {
  default = 2
  type    = number
}

variable "number" {
  default = true
  type    = bool
}

variable "override_special" {
  default = "!@#$%&*()-_=+[]{}<>:?"
  type    = string
}

variable "special" {
  default = true
  type    = bool
}

variable "upper" {
  default = true
  type    = bool
}
