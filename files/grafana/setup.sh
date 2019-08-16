#!/bin/bash

# Taken from https://github.com/grafana/grafana-docker/issues/74

# Script to configure grafana datasources and dashboards.
# Intended to be run before grafana entrypoint...
# Image: grafana/grafana:4.1.2
# ENTRYPOINT [\"/run.sh\"]"

GRAFANA_URL=${GRAFANA_URL:-http://localhost:3000}
DATASOURCES_PATH=${DATASOURCES_PATH:-/etc/grafana/datasources}
DASHBOARDS_PATH=${DASHBOARDS_PATH:-/etc/grafana/dashboards}
NOTIFIERS_PATH=${NOTIFIERS_PATH:-/etc/grafana/notifiers}
USERS_PATH=${USERS_PATH:-/etc/grafana/users}

# Generic function to call the Vault API
grafana_api() {
  local verb=$1
  local url=$2
  local params=$3
  local bodyfile=$4
  local response
  local cmd

  cmd="curl -L -s --fail -H \"Accept: application/json\" -H \"Content-Type: application/json\" --basic --user \"$GF_SECURITY_ADMIN_USER:$GF_SECURITY_ADMIN_PASSWORD\" -X ${verb} -k ${GRAFANA_URL}${url}"
  [[ -n "${params}" ]] && cmd="${cmd} -d \"${params}\""
  [[ -n "${bodyfile}" ]] && cmd="${cmd} --data @${bodyfile}"
  echo "Running ${cmd}"
  eval ${cmd} || return 1
  return 0
}

wait_for_api() {
  while ! grafana_api GET /api/user/preferences; do
    sleep 5
  done
}

install_datasources() {
  local datasource

  for datasource in ${DATASOURCES_PATH}/*.json; do
    if [[ -f "${datasource}" ]]; then
      echo "Installing datasource ${datasource}"
      if grafana_api POST /api/datasources "" "${datasource}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi
    fi
  done
}

install_dashboards() {
  local dashboard

  for dashboard in ${DASHBOARDS_PATH}/*.json; do
    if [[ -f "${dashboard}" ]]; then
      echo "Installing dashboard ${dashboard}"

      if grafana_api POST /api/dashboards/db "" "${dashboard}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi

    fi
  done
}

install_notifiers() {
  local notifier

  for notifier in ${NOTIFIERS_PATH}/*.json; do
    if [[ -f "${notifier}" ]]; then
      echo "Installing dashboard ${notifier}"

      if grafana_api POST /api/alert-notifications "" "${notifier}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi
    fi
  done
}

install_users() {
  local user

  for user in ${USERS_PATH}/*.json; do
    if [[ -f "${user}" ]]; then
      echo "Installing dashboard ${user}"

      if grafana_api POST /api/admin/users "" "${user}"; then
        echo "installed ok"
      else
        echo "install failed"
      fi

    fi
  done
}

configure_grafana() {
  wait_for_api
  install_datasources
  install_dashboards
  install_notifiers
  install_users
}

echo "Running configure_grafana in the background..."
configure_grafana &
/run.sh
exit 0
