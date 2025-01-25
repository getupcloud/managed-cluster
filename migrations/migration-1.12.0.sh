#!/bin/bash

source /etc/profile.d/getup.sh
source $REPO_DIR/migrations/migration-lib.sh

set -u

if ${MIGRATION_EXIT_ON_FAIL:-true}; then
  set -e
fi

info "Verifying if it's necessary to migrate flux module..."

if [ "$cluster_type" == kubespray ]; then
  info "Checking if required variable variable is defined: terraform_mode"

  if [ "$(get_tf_config TERRAFORM_MODE terraform_mode x)" == x ]; then
    kubespray-mode terraform-install
    unset_tf_config deploy_components
  fi
fi


ask_execute_command managed-cluster sync-template
ask_execute_command terraform-upgrade

info "Upgrading flux to v2.3.0 (forced)"
set_tf_config flux_version v2.3.0

migrate_resource \
 'module.cluster.module.flux.kubectl_manifest.flux-namespace' \
 'module.cluster.module.flux.kubernetes_namespace_v1.flux-namespace' \
 flux-system

current_repo_version=$(fmt_version $(get_current_version))

INDEXES=( $(terraform state list | sed -ne 's/module.cluster.module.flux.kubectl_manifest.flux\["\([^"]\+\)"]$/\1/p') )
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
    "module.cluster.module.flux.kubectl_manifest.flux[\"$idx\"]" \
    "module.cluster.module.flux.kubernetes_manifest.flux[\"$idx\"]" \
    "$id"
done
