## Provider specific variables
## Copy to toplevel

variable "api_endpoint" {
  description = "Kubernetes API endpoint"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes rersion"
  type        = string
  validation {
    condition     = can(regex("^v[0-9]\\.[0-9]+\\.[0-9]+", var.kubernetes_version))
    error_message = "Kubernetes version must match format `v{MAJOR}.{MINOR}.{PATCH}`."
  }
}

variable "region" {
  description = "Cluster region"
  type        = string
  default     = "unknown"
}

variable "terraform_mode" {
  description = "Select terraform \"mode\" to run: \"terraform-provision\" must be used before kubespray; \"terraform-install\" must be used after kubespary is finished and the basic of the cluster is already up."
  type        = string
  default     = "terraform-provision"
  validation {
    condition     = contains(["terraform-provision", "terraform-install"], var.terraform_mode)
    error_message = "terraform_mode: invalid value. One of terraform-provision or terraform-install."
  }
}

variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "refs/tags/v2.26.0"
}

variable "kubespray_dir" {
  description = "Kubespray install dir"
  type        = string
  default     = "/usr/share/kubespray"
}

variable "inventory_file" {
  description = "Kubespray inventory file"
  type        = string
  default     = "hosts.yaml"
}

variable "master_nodes" {
  description = "List of master nodes to provision"
  type        = list(any)
  default = [
    {
      address : "1.1.1.1",
      hostname : "master-0-change-me",
      ssh_private_key : "~/.ssh/id_rsa",

      disks : {
        containers : {
          device : "/dev/sdX",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        },
        kubelet : {
          device : "/dev/sdY",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        etcd : {
          device : "/dev/sdZ",
          mountpoint : "/var/lib/etcd",
          filesystem : "ext4",
          format : false
        }
      }
    }
  ]
}
variable "infra_nodes" {
  description = "List of worker nodes to provision"
  type        = list(any)
  default = [
    {
      address : "1.1.1.2",
      hostname : "infra-0-change-me",

      disks : {
        kubelet : {
          device : "/dev/sdX",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdY",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    },
    {
      address : "1.1.1.3",
      hostname : "infra-1-change-me",

      disks : {
        kubelet : {
          device : "/dev/sdX",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdY",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    }
  ]
}

variable "app_nodes" {
  description = "List of worker nodes to provision"
  type        = list(any)
  default = [
    {
      address : "1.1.1.4",
      hostname : "app-0-change-me",

      disks : {
        kubelet : {
          device : "/dev/sdX",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdY",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    },
    {
      address : "1.1.1.5",
      hostname : "app-1-change-me",

      disks : {
        kubelet : {
          device : "/dev/sdX",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdY",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    }
  ]
}

## labels

variable "default_master_node_labels" {
  description = "Default labels for master nodes"
  type        = map(any)
  default = {
    role : "master"
    "node-role.kubernetes.io/master" : ""
  }
}

variable "default_infra_node_labels" {
  description = "Default labels for infra nodes"
  type        = map(any)
  default = {
    role : "infra"
    "node-role.kubernetes.io/infra" : ""
  }
}

variable "default_app_node_labels" {
  description = "Default labels for app nodes"
  type        = map(any)
  default = {
    role : "app"
    "node-role.kubernetes.io/app" : ""
  }
}

## taints

variable "default_master_node_taints" {
  description = "Default taints for master nodes"
  type        = list(string)
  default = [
    "node-role.kubernetes.io/control-plane:NoSchedule"
  ]
}

variable "default_infra_node_taints" {
  description = "Default taints for infra nodes"
  type        = list(string)
  default = [
    "dedicated=infra:NoSchedule"
  ]
}

variable "default_app_node_taints" {
  description = "Default taints for app nodes"
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Path for SSH private key"
  type        = string
  default     = "identity"
}

variable "ssh_bastion_host" {
  description = "SSH password"
  type        = string
  default     = null
}

variable "ssh_bastion_user" {
  description = "SSH bastion username"
  type        = string
  default     = null
}

variable "ssh_bastion_password" {
  description = "SSH bastion password"
  type        = string
  default     = null
}

variable "ssh_bastion_private_key" {
  description = "Path for SSH bastion private key"
  type        = string
  default     = ""
}

variable "install_packages" {
  description = "Extra packages to install on nodes"
  type        = list(string)
  default     = []
}

variable "uninstall_packages" {
  description = "Extra packages to uninstall from nodes"
  type        = list(string)
  default     = []
}

variable "install_packages_default" {
  description = "Packages to install by default on nodes"
  type        = list(string)
  default = [
    "kernel-devel",
    "kernel-headers",
    "clang",
    "llvm",
    "chrony",
    "conntrack-tools",
    "git",
    "iproute-tc",
    "iscsi-initiator-utils",
    "jq",
    "moreutils",
    "netcat",
    "NetworkManager",
    "python3-openshift",
    "python3-passlib",
    "python3-pip",
    "python3-pyOpenSSL",
    "python3-virtualenv",
    "strace",
    "tcpdump"
  ]
}

variable "uninstall_packages_default" {
  description = "Packages to uninstall by default on nodes"
  type        = list(string)
  default = [
    "firewalld",
    "ntpd"
  ]
}

variable "etc_hosts" {
  description = "Entries to add to /etc/hosts on each node, Example: {\"1.1.1.1\":\"example.com example.io\"}"
  type        = map(string)
  default     = {}
}

variable "systemctl_enable" {
  description = "Services to enable on nodes"
  type        = list(string)
  default = [
    "chronyd",
    "iscsid"
  ]
}

variable "systemctl_disable" {
  description = "Services to disable on nodes"
  type        = list(string)
  default     = []
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  type        = string
  default     = "ln -fs $CLUSTER_DIR/artifacts/admin.conf $KUBECONFIG"
}
