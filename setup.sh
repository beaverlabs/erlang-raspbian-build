#!/bin/bash

set -e

SE_CONTAINER_NAME=beaverlabs_build
SE_CONTAINER_EXISTS=$(lxc-ls | grep "^$SE_CONTAINER_NAME" | sed 's/ *$//g')
SE_CONTAINER_RUNNING=$(lxc-ls --running | grep "^$SE_CONTAINER_NAME" | sed 's/ *$//g')

if [[ "$SE_CONTAINER_EXISTS" != "$SE_CONTAINER_NAME" ]]; then
  echo "Creating container..."
  lxc-create -t download -n $SE_CONTAINER_NAME -- -d debian -r stretch -a amd64
fi


if [[ "$SE_CONTAINER_RUNNING" != "$SE_CONTAINER_NAME" ]]; then
  echo "Starting container..."
  lxc-start -n $SE_CONTAINER_NAME
fi

echo "Copying files..."
cp ./files/build_elixir_deb.sh $HOME/.local/share/lxc/$SE_CONTAINER_NAME/rootfs/opt/
cp ./files/build_erlang_deb.sh $HOME/.local/share/lxc/$SE_CONTAINER_NAME/rootfs/opt/
cp ./files/setup_container.sh $HOME/.local/share/lxc/$SE_CONTAINER_NAME/rootfs/opt/

echo "Installing dependencies..."
lxc-attach -n $SE_CONTAINER_NAME /opt/install_dependencies.sh $2

echo "Done!"
