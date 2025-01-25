#!/bin/bash

source /etc/profile.d/getup.sh
source $REPO_DIR/migrations/migration-lib.sh

set -u

if ${MIGRATION_EXIT_ON_FAIL:-true}; then
  set -e
fi

info "Verifying if it's necessary to migrate flux module..."

if terraform state list | grep -q '^module.cluster.module.flux.kubectl_manifest.flux-git-repository\["GitRepository_flux-system_cluster"]'; then
  info "It's all good."
  exit
fi

ask_execute_command managed-cluster sync-template
ask_execute_command terraform-upgrade
