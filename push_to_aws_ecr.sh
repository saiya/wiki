#!/bin/bash -xe
cd $(dirname $0)
TAG_BASE_NAME=$(basename $(pwd))

echo 'Login to ECR'
$(aws ecr get-login --region=ap-northeast-1 --no-include-email)

ECR_ROOT_URL=$(cat ~/.docker/config.json | jq -r '.auths | keys | .[]' | head -1)
ECR_PUSH_TO="${ECR_ROOT_URL}/${TAG_BASE_NAME}:latest"

docker build -t ${TAG_BASE_NAME} .
docker tag ${TAG_BASE_NAME}:latest ${ECR_PUSH_TO}
docker push ${ECR_PUSH_TO}
