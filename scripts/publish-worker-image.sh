#!/bin/bash

VERSION=$1
ACCOUNT_ID=$2
REGION=$3
REGION=${REGION:-us-west-2}
REPOSITORY=$4
REPOSITORY=${REPOSITORY:-ecs-poc-worker}

if [ -z "$VERSION" ]
then
    echo "VERSION is required"
    exit 1
fi

if [ -z "$ACCOUNT_ID" ]
then
    echo "ACCOUNT_ID is required"
    exit 1
fi

docker build -t $REPOSITORY:$VERSION -f apps/server/Dockerfile ./apps/server
docker tag $(docker images -q $REPOSITORY:$VERSION) $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:$VERSION
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY:$VERSION