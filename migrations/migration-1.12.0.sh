#!/bin/bash

source /etc/profile.d/getup.sh
source $REPO_DIR/migrations/migration-lib.sh

set -u

if ${MIGRATION_EXIT_ON_FAIL:-true}; then
  set -e
fi

info "Verifying if it's necessary to migrate flux module..."

if ! terraform state list | grep -q '^module.cluster.module.flux\[0].kubectl_manifest.flux-namespace$'; then
  info "It's all good."
  exit
fi

if [ "$cluster_type" == kubespray ]; then
  info "Checking if required variable variable is defined: terraform_mode"

  if [ "$(get_tf_config TERRAFORM_MODE terraform_mode x)" == x ]; then
    kubespray-mode terraform-install
    unset_tf_config deploy_components
  fi
fi

ask_execute_command managed-cluster sync-template
ask_execute_command terraform-upgrade

migrate_resource \
 'module.cluster.module.flux[0].kubectl_manifest.flux-namespace' \
 'module.cluster.module.flux[0].kubernetes_namespace_v1.flux-namespace' \
 flux-system

current_repo_version=$(fmt_version $(get_current_version))

if [ $current_repo_version -lt $(fmt_version 1.12.15) ]; then
  migrate_resource \
   'module.cluster.module.flux[0].kubectl_manifest.flux-git-repository["Secret_flux-system_cluster"]' \
   'module.cluster.module.flux[0].kubernetes_manifest.flux-git-repository["Secret_flux-system_cluster"]' \
   apiVersion=v1,kind=Secret,namespace=flux-system,name=cluster

  migrate_resource \
   'module.cluster.module.flux[0].kubectl_manifest.flux-git-repository["Kustomization_flux-system_cluster"]' \
   'module.cluster.module.flux[0].kubernetes_manifest.flux-git-repository["Kustomization_flux-system_cluster"]' \
   apiVersion=kustomize.toolkit.fluxcd.io/v1,kind=Kustomization,namespace=flux-system,name=cluster

  migrate_resource \
   'module.cluster.module.flux[0].kubectl_manifest.flux-git-repository["GitRepository_flux-system_cluster"]' \
   'module.cluster.module.flux[0].kubernetes_manifest.flux-git-repository["GitRepository_flux-system_cluster"]' \
   apiVersion=source.toolkit.fluxcd.io/v1,kind=GitRepository,namespace=flux-system,name=cluster
fi

INDEXES=( $(terraform state list | sed -ne 's/module.cluster.module.flux\[0].kubectl_manifest.flux\["\([^"]\+\)"]$/\1/p') )
API_RESOURCES=$(kubectl api-resources)

for idx in ${INDEXES[@]}; do
  id=( $(tr -t _ ' ' <<<$idx) )
  kind=${id[0]}
  apiVersion=$(awk -v kind=$kind '
    $NF == kind {
      if (kind == "NetworkPolicy") {
        print "networking.k8s.io/v1"
      } else if (NF == 5) {
        print $3
      } else {
        print $2
      }
      exit
    }' <<<$API_RESOURCES)

  if [ ${#id[@]} -eq 2 ]; then
    # non-namespaced
    name=${id[1]}
    id="apiVersion=$apiVersion,kind=$kind,name=$name"
  elif [ ${#id[@]} -eq 3 ]; then
    # namespaced
    namespace=${id[1]}
    name=${id[2]}
    id="apiVersion=$apiVersion,kind=$kind,namespace=$namespace,name=$name"
  fi

  migrate_resource \
    "module.cluster.module.flux[0].kubectl_manifest.flux[\"$idx\"]" \
    "module.cluster.module.flux[0].kubernetes_manifest.flux[\"$idx\"]" \
    "$id"
done
