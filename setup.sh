#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "usage: ./setup.sh TARGET"
  exit 1;
fi

TARGET=$1
IMAGE_NAME=beaverlabs/erlixir:$1

if docker image ls | grep -q "^$IMAGE_NAME"; then
  echo "$IMAGE_NAME: Image already exists!"
else
  echo "Creating image $IMAGE_NAME..."
  docker build -t $IMAGE_NAME images/$1
fi

echo "Done!"
