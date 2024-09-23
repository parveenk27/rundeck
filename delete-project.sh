#!/usr/bin/env bash
set -euo pipefail

export RD_URL='http://rundeck:4440'
export RD_AUTH_PROMPT=false
export RD_TOKEN='xxx'

source "rd_lib.bash"

function usage() {
  printf "usage: %s\n" "${0} rundeck-project-name"
  printf "\n"
  printf "Description: %s\n" "Delete a Rundeck project."
  printf "\n"
  printf "%s\n" "First argument will be used as the Rundeck project name."
  printf "\n"
  printf "%s\n" "Options:"
  printf "\n"
  printf "%s\t%s\n" "-h" "Show help"
}

function rd_project_scm_clean_import() {
  local -r project_name="${1}"

  rd_project_scm_disable_import "${project_name}"
  # TODO: Clean up the ScmImport
}

function rd_project_scm_clean_export() {
  local -r project_name="${1}"

  rd_project_scm_disable_export "${project_name}"
  # TODO: Clean up the ScmExport
}

function main() {
  if [[ "${#}" -ne 1 ]]; then
    usage
    exit 1
  fi

  if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]]; then
    usage
    exit 0
  fi

  local -r project_name="${1}"

  rd_project_scm_clean_import "${project_name}"
  rd_project_scm_clean_export "${project_name}"
  rd_delete_project "${project_name}"
}

main "${@}"
