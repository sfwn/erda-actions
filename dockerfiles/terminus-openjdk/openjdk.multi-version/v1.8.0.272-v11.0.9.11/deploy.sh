#!/bin/bash
set -eo pipefail

cd "$(dirname "$0")"

image=registry.erda.cloud/erda/openjdk:multi-version-8-and-11
docker build . -t ${image}
docker push ${image}
echo "action meta: openjdk.multi-version-8-and-11=${image}"

image2=registry.erda.cloud/erda/openjdk:multi-version-v1.8.0.272-v11.0.9.11
docker tag ${image} ${image2}
docker push ${image2}
echo "action meta: openjdk.multi-version-v1.8.0-272-v11.0.9.11=${image2}"
