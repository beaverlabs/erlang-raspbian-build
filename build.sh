#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" || !($1 == "elixir" || $1 == "erlang") ]]; then
  echo "usage: ./build.sh erlang|elixir <release>"
  exit 1;
fi

SE_CONTAINER_NAME=beaverlabs_build

if [[ "$1" == "elixir" ]]; then
  lxc-attach -n $SE_CONTAINER_NAME /opt/build_elixir_deb.sh $2
  cp $HOME/.local/share/lxc/$SE_CONTAINER_NAME/rootfs/elixir_$2-1_all.deb .
  chown $USER:$USER elixir_$2-1_all.deb
fi

if [[ "$1" == "erlang" ]]; then
  lxc-attach -n $SE_CONTAINER_NAME /opt/build_erlang_deb.sh $2
  cp $HOME/.local/share/lxc/$SE_CONTAINER_NAME/rootfs/erlang_$2-1_armhf.deb .
  chown $USER:$USER erlang_$2-1_armhf.deb
fi
