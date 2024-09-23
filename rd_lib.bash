#!/usr/bin/env bash
set -euo pipefail

function rd_project_exists() {
  local -r project_name="${1}"
  rd projects info -p "${1}" &> /dev/null || { printf "%s" "false"; return; }

  printf "%s" "true"
}

function rd_create_project() {
  local -r project_name="${1}"

  # Fail if project name is 'Production'
  if [[ "${project_name}" == "Production" ]]; then
    printf "%s\n" "Project name 'Production' is reserved."
    printf "%s\n" "Please choose a different name for your project."
    exit 1
  fi

  rd projects create --project "${project_name}"
}

function rd_delete_project() {
  local -r project_name="${1}"

  # Fail if project name is 'Production'
  if [[ "${project_name}" == "Production" ]]; then
    printf "%s\n" "Project name 'Production' is reserved."
    exit 1
  fi

  rd projects delete --confirm --project "${project_name}"
}

function rd_project_scm_disable_import() {
  local -r project_name="${1}"

  rd projects scm disable \
    --project "${project_name}" \
    --integration import \
    --type "git-import"
}

function rd_project_scm_setup_import() {
  local -r project_name="${1}"
  local -r git_import_branch_name="${2:-main}"
  local -r project_dir="/home/rundeck/projects/${project_name}/ScmImport"
  local -r tmp_filepath="$(mktemp)"

  # shellcheck disable=SC2016
  local -r scm_import_json='{
    "config": {
      "strictHostKeyChecking": "no",
      "gitPasswordPath": "",
      "format": "json",
      "dir": "/home/rundeck/projects/user/ScmImport",
      "branch": "main",
      "url": "http://gitea:3000/root/rundeck-jobs-as-code.git",
      "filePattern": ".*\\.json",
      "useFilePattern": "true",
      "pathTemplate": "${job.sourceId}.${config.format}",
      "importUuidBehavior": "archive",
      "sshPrivateKeyPath": "",
      "fetchAutomatically": "false",
      "pullAutomatically": "false"
    }
  }'

  jq --arg project_dir "${project_dir}" \
    --arg branch_name "${git_import_branch_name}" \
    '.config.dir = $project_dir | .config.branch = $branch_name' \
    <<< "${scm_import_json}" > "${tmp_filepath}"

  rd projects scm setup \
    --project "${project_name}" \
    --integration import \
    --type "git-import" \
    --file "${tmp_filepath}"

  # Remove temp file
  rm -fv "${tmp_filepath}"
}

function rd_project_scm_import_jobs() {
  local -r project_name="${1}"
  local -r action_name='import-jobs'

  rd projects scm perform \
    --project "${project_name}" \
    --integration import \
    --action "${action_name}" \
    --allitems
}

function rd_project_scm_disable_export() {
  local -r project_name="${1}"

  rd projects scm disable \
    --project "${project_name}" \
    --integration export \
    --type "git-export"
}

function rd_project_scm_setup_export() {
  local -r project_name="${1}"
  local -r git_export_branch_name="${2}"
  local -r git_main_branch_name="main"
  local -r project_dir="/home/rundeck/projects/${project_name}/ScmExport"
  local -r tmp_filepath="$(mktemp)"

  # shellcheck disable=SC2016
  local -r scm_export_json='{
    "config": {
      "strictHostKeyChecking": "no",
      "gitPasswordPath": "",
      "format": "json",
      "baseBranch": "main",
      "exportUuidBehavior": "original",
      "dir": "/home/rundeck/projects/user/ScmExport",
      "committerEmail": "${user.email}",
      "branch": "rundeck/test",
      "url": "git@gitea:root/rundeck-jobs-as-code.git",
      "pathTemplate": "${job.sourceId}.${config.format}",
      "sshPrivateKeyPath": "keys/project/user_test/user",
      "committerName": "${user.fullName}",
      "fetchAutomatically": "true",
      "pullAutomatically": "false"
    }
  }'

  jq --arg project_dir "${project_dir}" \
    --arg main_branch "${git_main_branch_name}" \
    --arg export_branch "${git_export_branch_name}" \
    '.config.dir = $project_dir | .config.baseBranch = $main_branch | .config.branch = $export_branch' \
    <<< "${scm_export_json}" > "${tmp_filepath}"

  rd projects scm setup \
    --project "${project_name}" \
    --integration export \
    --type "git-export" \
    --file "${tmp_filepath}"

  rm -fv "${tmp_filepath}"
}
