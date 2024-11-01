#!/bin/bash

source /etc/profile.d/getup.sh

set -u

if ${MIGRATION_EXIT_ON_FAIL:-true}; then
  set -e
fi

info "Verifying if it's necessary to migrate flux module..."

if ! terraform state list | grep -q '^module.cluster.module.flux\[0].kubectl_manifest.flux-namespace$'; then
  info "It's all good."
  exit
fi

function migrate_resource()
{
  if [ $# -ne 3 ]; then
    warn "$0: migrate_resource: Invalid parameters. Expected 3, got $#"
    return 1
  fi

  local from="$1"
  local to="$2"
  local id="$3"

  fill_line Migrating resources

  info "Importing $to $id"
  ask_execute_command terraform import "$to" "$id"

  info "Removing $from"
  ask_execute_command terraform state rm "$from" || true
}

ask_execute_command managed-cluster sync-template
ask_execute_command terraform-upgrade

migrate_resource \
 'module.cluster.module.flux[0].kubectl_manifest.flux-namespace' \
 'module.cluster.module.flux[0].kubernetes_namespace_v1.flux-namespace' \
 flux-system

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
