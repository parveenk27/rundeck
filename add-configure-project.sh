#!/usr/bin/env bash
set -euo pipefail

export RD_URL='http://rundeck:4440'
export RD_AUTH_PROMPT=false
export RD_TOKEN='xxxx'

source "rd_lib.bash"

function usage() {
  printf "usage: %s\n" "${0} rundeck-project-name export-git-branch-name"
  printf "\n"
  printf "Description: %s\n" "Add and configure a Rundeck project."
  printf "\n"
  printf "%s\n" "First argument will be used as the Rundeck project name."
  printf "%s " "Second argument will be used as the Git branch name to configure"
  printf "%s\n" "the Git scm export to push your changes (e.g. modified Rundeck jobs)"
  printf "\n"
  printf "%s\n" "Options:"
  printf "\n"
  printf "%s\t%s\n" "-h" "Show help"
}

function main() {
  if [[ "${#}" -ne 2 ]]; then
    usage
    exit 1
  fi

  local -r project_name="${1}"
  local -r export_branch_name="${2}"

  rd_create_project "${project_name}"
  rd_project_scm_setup_import "${project_name}"
  rd_project_scm_import_jobs "${project_name}"
  rd_project_scm_disable_import "${project_name}"
  rd_project_scm_setup_export "${project_name}" "${export_branch_name}"
}

main "${@}"
