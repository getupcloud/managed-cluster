# Creating a cluster

## Architecture

![Architecture](./docs/architecture.png)

## Bootstrap from base repository

### Clone this repo and give it a meaningful name:

```sh
$ git clone git@github.com:getupcloud/managed-cluster.git managed-cluster-evilcorp
$ cd managed-cluster-evilcorp
```

### Install required tools as root:

```sh
$ sudo make install
```

### Install docker or compatible

This depends on your distro. Fedora/Centos based distros can install either podman or moby-engine.


### Bootstrap an initial config for a new cluster named `production`:

```sh
$ ./managed-cluster create
```

The cluster configs will be stored inside the directory `./clusters/${CLUSTER_NAME}/${CLUSTER_TYPE}`.

## Start installer container

We are now ready to create our cluster. Let's start the installer container.

```sh
$ ./managed-cluster start
```

There are two volumes mapped from local host into container's filesystem:

- `./clusters/${CLUSTER_NAME}/${CLUSTER_TYPE}` -> `/cluster`
- `./` -> `/repo`

A new `/cluster/terraform.tfvars` will be generated in case none is found.
You will be asked to fill in non-default values. After that, if you need to update/change values from `terraform.tfvars` simply run `terraform-edit`
or `vim /cluster/terraform.tfvars`.

> In order to re-generate `terraform.tfvars`, run `terraform-setup -f`.
> Any manually-edited values in this file will be lost.

## Apply terraform

We can now create our cluster using terraform. Run this to init, verify, apply and check the new cluster:

```
$ terraform-apply
```

After terraform finishes, you will be asked to create a github repo and push this repo into it.

Flux will be installed and configured to sync from `${GITHUB_REPO}/clusters/${CLUSTER_NAME}/${CLUSTER_TYPE}/manifests/cluster/kustomization.yaml`.

### Kubespary/OnpPremises only

The first time you run terraform-apply, it will provision the hosts (install basic packages, configure swap, format disks, etc).
After that, you must manually start kubespray using the command:

```sh
$ kubespray-apply
```

If kubespray finishes with success, run `terraform-apply` again.

From now, it will not `provision` hosts anymore, and will only commit and push flux manifests to git (`install` mode).
In case you need to re-provision the hosts (maybe to add new hosts or update the OS), go back to `provision` mode with:

```sh
$ kubespray-mode terraform-provision
```

## Updating the cluster

In order to update any config, simply `terraform-edit` and then `terraform-apply`.

You are free to edit/add/remove anything from `/cluster` (or `clusters/${CLUSTER_NAME}/${CLUSTER_TYPE}` if you are outside of the container).

# Workflow

This is the complete workflow (created in https://asciiflow.com)

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                                   │
│          ##################                               ##################                                                      │
│          # CREATE CLUSTER #                               # UPDATE CLUSTER #                                                      │
│          ##################                               ##################                                                      │
│                  │                                                │                                                               │
│                  │                                                │                                                               │
│                  │                                                │                                                               │
│                  ▼                                                ▼                                                               │
│      ┌────────────────────────┐                      ┌──────────────────────────┐                                                 │
│      │ managed-cluster create │                      │ git clone $remote-origin │                                                 │
│      └───────────┬────────────┘                      └────────────┬─────────────┘                                                 │
│                  │                                                │                                                               │
│                  │                                                │                                                               │
│                  ▼                                                │                                                               │
│      ┌───────────────────────┐                                    ▼                                                               │
│      │ managed-cluster start │◄────────────┐       ┌──────────────────────────────┐*                                              │
│      └───────────┬───────────┘             │       │ managed-cluster remote-setup │                                               │
│                  │                         │       └──────────────┬───────────────┘                                               │
│                  │                         │                      │                                                               │
│   ┌──────────────┼───────────────┐         │                      │                                                               │
│   │ container    │               │         │                      │                         ┌─────────────────────────┐           │
│   │              ▼               │         │                      ▼                      ┌──┤ git pull origin         │           │
│   │     ┌─────────────────┐*     │         │         ┌───────────────────────────┐       │  └─────────────────────────┘           │
│   │     │ terraform-setup │      │         │         │ managed-cluster repo-pull │◄──────┤                                        │
│   │     └────────┬────────┘      │         │         └────────────┬──────────────┘       │  ┌────────────────────────────┐        │
│   │              │               │         │                      │                      └──┤ git fetch upstream         │        │
│   │              │               │         │                      │                         └────────────────────────────┘        │
│   │              │               │         │                      │                                                               │
│   │              ▼               │         │                      │                                                               │
│   │     ┌────────────────┐       │         │                      │                            ┌────────────────────────────┐     │
│   │     │ terraform-edit │       │         │                      ▼                         ┌──┤ git fetch upstream         │     │
│   │     └────────┬───────┘       │         │           ┌────────────────────────┐           │  └────────────────────────────┘     │
│   │              │               │         │           │ managed-cluster update │◄──────────┤                                     │
│   │              │               │         │           └──────────┬─────────────┘           │  ┌───────────────────────┐          │
│   │              │               │         │                      │                         └──┤ git merge $latest-tag │          │
│   │              ▼               │         │                      │                            └───────────────────────┘          │
│   │     ┌──────────────────┐     │         │                      │                                                               │
│   │     │ terraform-apply  │◄─┐  │         │                      │                                                               │
│   │     └────────┬─────────┘  │  │         │                      │                                                               │
│   │              │            │  │         │                      │                        ┌──────────────────────────────┐       │
│   │              │            │  │         │                      ▼                     ┌──┤ rsync templates/ -> /cluster │       │
│   │              │            │  │         │       ┌───────────────────────────────┐    │  └──────────────────────────────┘       │
│   │              ▼            │  │         └───────┤ managed-cluster sync-template │◄───┤                                         │
│   │     ┌─────────────────┐** │  │                 └───────────────────────────────┘    │  ┌────────────────────────────────────┐ │
│   │     │ kubespray-apply │───┘  │                                                      └──┤ rsync templates/$type/ -> /cluster │ │
│   │     └─────────────────┘      │                                                         └────────────────────────────────────┘ │
│   └──────────────────────────────┘                                                                                                │
│                                                                                                                                   │
│ * required only once         ** kubespray only                                                                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
