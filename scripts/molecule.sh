#!/usr/bin/env bash
set -euo pipefail

# Local-only helper for running Molecule against OpenStack without committing credentials.
#
# Usage:
#   ./scripts/molecule.sh test -s default
#
# Optional (recommended): create a local .env (ignored by git) containing:
#   OS_ENV_FILE=~/.openstack/openrc.sh
#
# This script will source $OS_ENV_FILE (if set) before invoking molecule.

if [[ -f "./.env" ]]; then
  # Export variables defined in .env so they are visible to the `molecule` subprocess
  # (Ansible lookups use process environment variables).
  set -a
  # shellcheck disable=SC1091
  source "./.env"
  set +a
fi

if [[ -n "${OS_ENV_FILE:-}" ]]; then
  os_env_file="${OS_ENV_FILE}"
  if [[ "${os_env_file}" == "~/"* ]]; then
    os_env_file="${HOME}/${os_env_file:2}"
  elif [[ "${os_env_file}" == "~" ]]; then
    os_env_file="${HOME}"
  fi

  if [[ ! -f "${os_env_file}" ]]; then
    echo "ERROR: OS_ENV_FILE points to a missing file: ${OS_ENV_FILE}" >&2
    exit 2
  fi
  set -a
  # shellcheck disable=SC1090
  source "${os_env_file}"
  set +a
fi

exec molecule "$@"
