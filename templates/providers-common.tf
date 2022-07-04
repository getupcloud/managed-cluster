provider "cronitor" {
  api_key = var.cronitor_api_key
}

provider "opsgenie" {
  api_key = var.opsgenie_api_key == "" ? "FAKE" : var.opsgenie_api_key
}

provider "shell" {
  enable_parallelism = true
  interpreter        = ["/bin/bash", "-c"]
}
