#!/bin/bash

set -e

SE_CONTAINER_NAME=beaverlabs_build
SE_CONTAINER_EXISTS=$(lxc-ls | grep "^$SE_CONTAINER_NAME")
SE_CONTAINER_RUNNING=$(lxc-ls --running | grep "^$SE_CONTAINER_NAME")

if [[ "$SE_CONTAINER_RUNNING" == "$SE_CONTAINER_NAME" ]]; then
  echo "Stopping container..."
  lxc-stop -n $SE_CONTAINER_NAME
fi

if [[ "$SE_CONTAINER_EXISTS" == "$SE_CONTAINER_NAME" ]]; then
  echo "Destroying container..."
  lxc-destroy -n $SE_CONTAINER_NAME
fi

echo "Done!"
