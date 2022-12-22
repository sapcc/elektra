#!/bin/bash

function help() {
  help_txt="$(basename -- $0) REGION* ENV_FILE* KUBE_CMD*
      REGION:   where to logon?                      default: qa-de-1
      ENV_FILE: where the elektra .env is located?   default: /workspace/elektra/.env
      KUBE_CMD: replace the kubectl command          default: kubectl
      "

  if [[ -n "${WS_USER}" ]]; then
    # shellcheck source=/dev/null
    source /usr/local/lib/wb/logger
    msg_help "$help_txt"
  else
    echo "HELP: $help_txt"
  fi
  exit
}

function disable_internal_endpoint() {
  sed -i '/^#MONSOON_OPENSTACK_AUTH_API_ENDPOINT="https:\/\/identity-3/s/^#//g' "$ENV_FILE"
  sed -i '/^MONSOON_OPENSTACK_AUTH_API_ENDPOINT="http:\/\/localhost:5000\/v3\/"/d' "$ENV_FILE"
}

function enable_internal_endpoint() {
  sed -i '/^MONSOON_OPENSTACK_AUTH_API_ENDPOINT="https:\/\/identity-3/s/^/#/' "$ENV_FILE"
  echo 'MONSOON_OPENSTACK_AUTH_API_ENDPOINT="http://localhost:5000/v3/"' >>"$ENV_FILE"
}

if [[ "$1" == "--help" ]]; then
  help
fi

REGION="${1-"qa-de-1"}"
ENV_FILE="${2-"/workspace/elektra/.env"}"
KUBE_CMD="${3-"kubectl"}"

# ctrl_c is not allowed
trap ctrl_c INT

CONNECT="$KUBE_CMD port-forward -n monsoon3 service/keystone 5000:5000"
PID=$(pidof $KUBE_CMD)

function ctrl_c() {
  echo ""
  echo "Do not exit with ctrl+c otherwise the kube proxy will not killed"
  echo "and will run in background forever 😶"
}

if [[ -z "${REGION}" ]]; then
  echo "ERROR: no REGION given"
  help
fi

if [[ -n "${WS_USER}" ]]; then
  # shellcheck source=/dev/null
  source /usr/local/lib/wb/logger
  msg_success "Workspace found 🙂"

  if [[ -n "${PID}" ]]; then
    msg_error "Running $KUBE_CMD found!"
    msg_info "Please check by yourself with 'ps aux | grep $KUBE_CMD'"
  fi

  if [ ! -f "$ENV_FILE" ]; then
    msg_error "No .env file $ENV_FILE found"
    help
  fi

  # first try to connect with switch
  switch-k8sCluster $REGION
  $CONNECT &
  echo ""
  sleep 3

  PID=$(pidof $KUBE_CMD)
  if [[ -z "${PID}" ]]; then
    msg_warning "There was a problem to connect to $REGION"
    # second try to connect with login
    echo ""
    logon-k8sCluster-oidc $REGION
    $CONNECT &
    echo ""
    sleep 3

    echo ""
    msg_success "Connected to internal keystone endpoint in $REGION"
    echo ""
  else
    echo ""
    msg_success "Connected to internal keystone endpoint in $REGION"
    echo ""
  fi

  PID=$(pidof $KUBE_CMD)
  if [[ -z "${PID}" ]]; then
    msg_error "Something went wrong, cannot find PID for $KUBE_CMD"
    msg_info "Please check by yourself with 'ps aux | grep $KUBE_CMD'"
    exit
  fi

  msg_info "Adjusted the .env to use internal keystone endpoint"
  enable_internal_endpoint
  msg_info "Please restart your elektra rails server"
  echo ""

  while true; do
    msg_info "The Tunnel is working in background with PID $PID"
    msg_info "Do you want to stop it? This will also restore your .env"
    read -p "Quit Tunnel (y) " yn
    case $yn in
    [Yy]*)
      kill $PID &&
        echo "" &&
        msg_info "Adjusted .env back to use external keystone endpoint" &&
        disable_internal_endpoint
      msg_info "Please restart your elektra rails server"
      break
      ;;
    *) echo "" ;;
    esac
  done

else
  echo "At the moment only workspaces supports auto login 🙃"
  echo "You need to logon to the destination cluster by yourself"

  if [[ -n "${PID}" ]]; then
    echo "ERROR: Running $KUBE_CMD found!"
    echo "Please check by yourself with 'ps aux | grep $KUBE_CMD'"
  fi

  if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: No .env file found"
    help
  fi

  $CONNECT &
  echo ""
  sleep 3
  PID=$(pidof $KUBE_CMD)

  if [[ -z "${PID}" ]]; then
    echo "ERROR: no running $KUBE_CMD found!"
    echo "Please check by yourself with 'ps aux | grep $KUBE_CMD'"
    exit
  fi

  echo ""
  echo "Connected to internal keystone endpoint in $REGION"
  echo ""

  echo "Adjusted the .env to use internal keystone endpoint"
  enable_internal_endpoint
  echo "Please restart your elektra rails server"
  echo ""

  while true; do
    echo "The Tunnel is working in background with PID $PID"
    echo "Do you want to stop it? This will also restore your .env"
    read -p "Quit Tunnel (y) " yn
    case $yn in
    [Yy]*)
      kill $PID &&
        echo "" &&
        echo "Adjusted .env back to use external keystone endpoint" &&
        disable_internal_endpoint &&
        echo "Please restart your elektra rails server"
      break
      ;;
    *) echo "" ;;
    esac
  done

fi
