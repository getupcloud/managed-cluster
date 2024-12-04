#!/bin/bash

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
  ask_execute_command terraform import "$to" "$id" || true

  info "Removing $from"
  ask_execute_command terraform state rm "$from" || true
}


