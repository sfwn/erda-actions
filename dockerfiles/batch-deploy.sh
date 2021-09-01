#!/bin/bash
set -e
set -u
set -x
set -o pipefail

registry="${DOCKER_REGISTRY-}"
username="${DOCKER_USERNAME-}"
password="${DOCKER_PASSWORD-}"

if [[ -z $registry ]]; then
    echo No registry specified! You should specify it through env "'DOCKER_REGISTRY'".
    exit 1
fi

if [[ -n $username && -n $password ]]; then
    echo "You specifed docker username&password, execute login step."
    docker login ${DOCKER_REGISTRY} -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
fi

# find all deploy.sh and deploy
deployFiles=$(find "$(cd $(dirname "$0"); pwd)" -type f -name deploy.sh)
for f in $deployFiles; do
    echo begin execute "$f"
    cd "$(dirname "$f")"
    bash deploy.sh
done
