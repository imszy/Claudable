#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-}"
MODE="${2:-}"

if [[ -z "${HOST}" ]]; then
  echo "Usage:"
  echo "  REPO_URL=... BRANCH=... $0 root@47.245.120.53 [--password]"
  exit 2
fi

REPO_URL="${REPO_URL:-https://github.com/imszy/Claudable.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-/opt/claudable/app}"

SSH_BIN="ssh"

if [[ "${MODE}" == "--password" ]]; then
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "Error: sshpass not found. Install it or use SSH key login."
    exit 2
  fi
  if [[ -z "${SSHPASS:-}" ]]; then
    echo "Error: SSHPASS is not set. Export SSHPASS in your shell before running."
    exit 2
  fi
  SSH_BIN="sshpass -e ssh"
fi

echo "Deploying to ${HOST}"
echo "  REPO_URL=${REPO_URL}"
echo "  BRANCH=${BRANCH}"
echo "  APP_DIR=${APP_DIR}"

${SSH_BIN} -o StrictHostKeyChecking=accept-new "${HOST}" \
  "REPO_URL='${REPO_URL}' BRANCH='${BRANCH}' APP_DIR='${APP_DIR}' bash -s" <<'REMOTE'
set -euo pipefail

: "${REPO_URL:?missing REPO_URL}"
: "${BRANCH:?missing BRANCH}"
: "${APP_DIR:?missing APP_DIR}"

echo "[1/6] Preparing directories..."
mkdir -p "${APP_DIR}"

echo "[2/6] Installing Docker if needed..."
if ! command -v docker >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker || true
  else
    echo "Unsupported OS (no apt-get). Please install Docker manually."
    exit 1
  fi
fi

echo "[3/6] Ensuring docker compose is available..."
if ! docker compose version >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y docker-compose-plugin
  else
    echo "docker compose not available. Please install docker-compose-plugin."
    exit 1
  fi
fi

echo "[4/6] Cloning/updating repository..."
cd "${APP_DIR}"
if [[ -d ".git" ]]; then
  git fetch --all --prune
else
  git clone "${REPO_URL}" .
fi

git checkout "${BRANCH}" || git checkout -b "${BRANCH}" "origin/${BRANCH}"
git pull --ff-only origin "${BRANCH}" || true

echo "[5/6] Preparing environment file..."
if [[ ! -f ".env" && -f ".env.production.example" ]]; then
  cp .env.production.example .env
  echo "Created ${APP_DIR}/.env from .env.production.example"
  echo "IMPORTANT: Edit .env and set ANTHROPIC_API_KEY (and ENCRYPTION_KEY) before using."
fi

mkdir -p data

echo "[6/6] Starting services (build + up)..."
docker compose up -d --build

echo "Done."
echo "Web:  http://$(hostname -I | awk '{print $1}'):3000"
echo "API:  http://$(hostname -I | awk '{print $1}'):8080"
echo "Docs: http://$(hostname -I | awk '{print $1}'):8080/docs"
REMOTE

