#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" || -z "$3" || !($2 == "elixir" || $2 == "erlang") ]]; then
  echo "usage: ./build.sh stretch|buster|bullseye erlang|elixir <release>"
  exit 1;
fi

SE_CONTAINER_NAME=docker.io/beaverlabs/erlixir:$1

if [[ "$2" == "elixir" ]]; then
  docker run -it -v "$(pwd)/shared":/mnt/shared $SE_CONTAINER_NAME /build_elixir_deb.sh $3 $4
fi

if [[ "$2" == "erlang" ]]; then
  docker run -it -v "$(pwd)/shared":/mnt/shared $SE_CONTAINER_NAME /build_erlang_deb.sh $1 $3
fi
