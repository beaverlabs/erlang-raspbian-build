#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" || !($1 == "elixir" || $1 == "erlang") ]]; then
  echo "usage: ./build.sh erlang|elixir <release>"
  exit 1;
fi

SE_CONTAINER_NAME=beaverlabs/erlixir

if [[ "$1" == "elixir" ]]; then
  docker run -it -v "$(pwd)/shared":/mnt/shared $SE_CONTAINER_NAME /build_elixir_deb.sh $2
fi

if [[ "$1" == "erlang" ]]; then
  docker run -it -v "$(pwd)/shared":/mnt/shared $SE_CONTAINER_NAME /build_erlang_deb.sh $2
fi
