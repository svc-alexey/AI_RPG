#!/usr/bin/env bash
# Safe production update on the home server (or any host with the repo).
# - Never overwrites backend/symmetry/.env if it exists.
# - Pulls latest code, rebuilds and restarts Docker stack.
#
# Usage (on server):
#   chmod +x scripts/deploy_home_server_safe.sh
#   APP_ROOT=/opt/ai-rpg/app ./scripts/deploy_home_server_safe.sh
#
# Usage (from your PC, password once):
#   ssh alexeyko@192.168.1.68 'bash -s' < scripts/deploy_home_server_safe.sh

set -euo pipefail

resolve_app_root() {
  if [[ -n "${APP_ROOT:-}" ]] && [[ -d "${APP_ROOT}/.git" ]]; then
    echo "${APP_ROOT}"
    return
  fi
  for candidate in /opt/ai-rpg/app /opt/ai-rpg; do
    if [[ -d "${candidate}/.git" ]]; then
      echo "${candidate}"
      return
    fi
  done
  echo ""
}

ROOT="$(resolve_app_root)"
if [[ -z "${ROOT}" ]]; then
  echo "ERROR: Git repo not found. Set APP_ROOT to your clone (e.g. /opt/ai-rpg/app)." >&2
  exit 1
fi

cd "${ROOT}"
echo "Using repo: ${ROOT}"

ENV_FILE="backend/symmetry/.env"
EXAMPLE="backend/symmetry/.env.production.example"
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: ${ENV_FILE} is missing." >&2
  echo "First-time setup only: copy ${EXAMPLE} to ${ENV_FILE} and fill secrets — do not commit .env." >&2
  exit 1
fi
echo "OK: preserving existing ${ENV_FILE} (not copying from example)."

git pull --ff-only

COMPOSE_FILE=""
if [[ -f docker-compose.prod.yml ]]; then
  COMPOSE_FILE="-f docker-compose.prod.yml"
elif [[ -f docker-compose.yml ]]; then
  COMPOSE_FILE="-f docker-compose.yml"
else
  echo "ERROR: No docker-compose.yml or docker-compose.prod.yml in ${ROOT}" >&2
  exit 1
fi

echo "docker compose ${COMPOSE_FILE} up --build -d"
docker compose ${COMPOSE_FILE} up --build -d

docker compose ${COMPOSE_FILE} ps

echo "Smoke: GET /health"
curl -fsS "http://127.0.0.1/health" && echo ""
echo "Done."
