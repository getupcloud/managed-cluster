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
  default     = "1.24"
}

variable "region" {
  description = "Cluster region"
  type        = string
  default     = "unknown"
}

variable "deploy_components" {
  description = "Either to deploy or not kubernetes components. Set to true after kubernetes is up and running."
  type        = bool
  default     = false
}

variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "remotes/origin/release-2.17"
}

variable "kubespray_dir" {
  description = "Kubespray install dir"
  type        = string
  default     = "/usr/share/kubespray"
}

variable "inventory_file" {
  description = "Kubespray inventory file"
  type        = string
  default     = "/cluster/hosts.yaml"
}

variable "master_nodes" {
  description = "List of master nodes to provision"
  type        = list(any)
  default = [
    {
      address : "10.0.0.1",
      hostname : "master-0",
      ssh_private_key : "~/.ssh/id_rsa",

      disks : {
        containers : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        },
        kubelet : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/kubelet"
          filesystem : "ext4",
          format : false
        }
        etcd : {
          device : "/dev/sdd",
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
      address : "10.0.0.10",
      hostname : "infra-0"

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    },
    {
      address : "10.0.0.11",
      hostname : "infra-1",

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdc",
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
      address : "10.0.0.20",
      hostname : "app-0"

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
          filesystem : "ext4",
          format : false
        }
      }
    },
    {
      address : "10.0.0.21",
      hostname : "app-1",

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
          filesystem : "ext4",
          format : false
        }
        containers : {
          device : "/dev/sdc",
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
    "node-role.kubernetes.io/control-plane:NoSchedule",
    "node-role.kubernetes.io/master:NoSchedule"
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
  default     = "/cluster/identity"
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
