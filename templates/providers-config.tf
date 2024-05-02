provider "shell" {
  enable_parallelism = true
  interpreter        = ["/bin/bash", "-c"]
}

provider "kustomization" {
  kubeconfig_raw = ""
}
