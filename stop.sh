#!/bin/zsh

DOCKER_COMPOSE="/usr/local/bin/docker-compose"
TRAEFIK_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

echo ${TRAEFIK_DIR}

cd ${TRAEFIK_DIR}

${DOCKER_COMPOSE} down || true
