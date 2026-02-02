#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202601290438-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  02-webui.sh --help
# @@Copyright        :  Copyright: (c) 2026 Jason Hempstead, Casjays Developments
# @@Created          :  Wednesday, Jan 29, 2026 04:38 UTC
# @@File             :  02-webui.sh
# @@Description      :  Start Open WebUI for Ollama
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :  
# @@Resource         :  
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/start-service
# - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - -
set -e
# - - - - - - - - - - - - - - - - - - - - - - - - -
# run trap command on exit
trap '__trap_err_handler' ERR
trap 'retVal=$?;if [ "$SERVICE_IS_RUNNING" != "yes" ] && [ -f "$SERVICE_PID_FILE" ]; then rm -Rf "$SERVICE_PID_FILE"; fi;exit $retVal' SIGINT SIGTERM SIGPWR
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ERR trap handler
__trap_err_handler() {
  local retVal=$?
  local command="$BASH_COMMAND"
  [ $retVal -eq 130 ] || [ $retVal -eq 141 ] && return $retVal
  if [[ "$command" =~ (mkdir|touch|chmod|chown|chgrp|ln|cp|mv|rm|echo|printf|cat|tee|sed|awk|grep|find|sort|uniq|adduser|addgroup|usermod|groupmod|id|getent) ]]; then
    return 0
  fi
  if [[ "$command" =~ (test|\[|\[\[|kill -0|pgrep|pidof|ps) ]]; then
    return 0
  fi
  if [ "$SERVICE_IS_RUNNING" != "yes" ]; then
    echo "❌ Critical error (exit $retVal): $command" >&2
    kill -TERM 1 2>/dev/null || exit $retVal
  fi
  return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - -
SCRIPT_FILE="$0"
SERVICE_NAME="webui"
SCRIPT_NAME="$(basename -- "$SCRIPT_FILE" 2>/dev/null)"
# - - - - - - - - - - - - - - - - - - - - - - - - -
__script_exit() {
  local exit_code="${1:-0}"
  if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return "$exit_code"
  else
    exit "$exit_code"
  fi
}
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Exit if service is disabled
if [ -n "$WEBUI_ENABLED" ]; then
  if [ "$WEBUI_ENABLED" != "yes" ]; then
    export SERVICE_DISABLED="$SERVICE_NAME"
    __script_exit 0
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$DEBUGGER" = "on" ] || [ -f "/config/.debug" ]; then
  echo "Enabling debugging"
  set -xo pipefail
  export DEBUGGER="on"
else
  set -o pipefail
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
export PATH="/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  if [ -f "$set_env" ]; then
    . "$set_env"
  fi
done
unset set_env
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set service state
SERVICE_IS_RUNNING="no"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set service paths
DATA_DIR="/data/webui"
CONF_DIR="/config/webui"
LOG_DIR="/data/logs/webui"
# - - - - - - - - - - - - - - - - - - - - - - - - -
SERVICE_PORT="${WEBUI_PORT:-80}"
RUNAS_USER="root"
SERVICE_UID="0"
SERVICE_GID="0"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Execute command - Use open-webui command directly
EXEC_CMD_BIN='open-webui'
EXEC_CMD_ARGS="serve --host ${WEBUI_HOST:-0.0.0.0} --port ${WEBUI_PORT:-80}"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Environment variables for Open WebUI
# If MODELS env var is set but DEFAULT_MODELS is not, use MODELS as DEFAULT_MODELS
# Derive OLLAMA_BASE_URL from OLLAMA_HOST if not explicitly set
OLLAMA_PORT_NUM="${OLLAMA_PORT:-11434}"
OLLAMA_BASE_URL_DEFAULT="http://127.0.0.1:${OLLAMA_PORT_NUM}"
CMD_ENV="OLLAMA_BASE_URL=\"${OLLAMA_BASE_URL:-${OLLAMA_BASE_URL_DEFAULT}}\",WEBUI_SECRET_KEY=\"${WEBUI_SECRET_KEY:-$(openssl rand -hex 32 2>/dev/null || echo 'changeme')}\",DATA_DIR=\"${DATA_DIR:-/data/webui}\",PORT=\"${WEBUI_PORT:-80}\",HOST=\"${WEBUI_HOST:-0.0.0.0}\",WEBUI_URL=\"${WEBUI_URL:-http://localhost:${WEBUI_PORT:-80}}\",ENABLE_SIGNUP=\"${ENABLE_SIGNUP:-true}\",DEFAULT_MODELS=\"${DEFAULT_MODELS:-${MODELS}}\",DEFAULT_USER_ROLE=\"${DEFAULT_USER_ROLE:-pending}\",ENABLE_ADMIN_EXPORT=\"${ENABLE_ADMIN_EXPORT:-true}\",WEBUI_NAME=\"${WEBUI_NAME:-Open WebUI}\",ENABLE_OAUTH_SIGNUP=\"${ENABLE_OAUTH_SIGNUP:-}\",OAUTH_MERGE_ACCOUNTS_BY_EMAIL=\"${OAUTH_MERGE_ACCOUNTS_BY_EMAIL:-}\""
# - - - - - - - - - - - - - - - - - - - - - - - - -
IS_WEB_SERVER="yes"
IS_DATABASE_SERVICE="no"
USES_DATABASE_SERVICE="no"
# - - - - - - - - - - - - - - - - - - - - - - - - -
APPLICATION_DIRS="$CONF_DIR $DATA_DIR $LOG_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Wait for Ollama to be ready
OLLAMA_PORT_NUM="${OLLAMA_PORT:-11434}"
echo "Waiting for Ollama to be ready on port ${OLLAMA_PORT_NUM}..."
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
  if curl -s http://127.0.0.1:${OLLAMA_PORT_NUM}/api/version >/dev/null 2>&1; then
    echo "✓ Ollama is ready"
    break
  fi
  sleep 1
  counter=$((counter + 1))
done

if [ $counter -eq $timeout ]; then
  echo "⚠ Warning: Ollama not responding after ${timeout}s, starting Web UI anyway"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Create required directories
mkdir -p "$DATA_DIR" "$CONF_DIR" "$LOG_DIR" 2>/dev/null || true
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if command exists
if [ ! -x "$(command -v $EXEC_CMD_BIN 2>/dev/null)" ]; then
  echo "❌ $EXEC_CMD_BIN is not installed or not executable"
  __script_exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Start service
echo "Starting Open WebUI on port $SERVICE_PORT..."

# Export environment variables
export OLLAMA_BASE_URL="http://127.0.0.1:11434"
export WEBUI_SECRET_KEY="${WEBUI_SECRET_KEY:-$(openssl rand -hex 32 2>/dev/null || echo 'changeme')}"
export DATA_DIR="/data/webui"
export PORT="80"

# Execute the command
exec $EXEC_CMD_BIN $EXEC_CMD_ARGS 2>&1 | tee -a "$LOG_DIR/webui.log" &
SERVICE_PID=$!

# Store PID
echo "$SERVICE_PID" > "/run/init.d/$SERVICE_NAME.pid"
SERVICE_IS_RUNNING="yes"

echo "✓ Open WebUI started with PID $SERVICE_PID"
echo "✓ Web UI available at http://localhost:$SERVICE_PORT"

__script_exit 0
