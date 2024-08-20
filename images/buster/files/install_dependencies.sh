#!/bin/bash

set -e

dpkg --add-architecture armhf
apt update && apt install --no-install-recommends -y ca-certificates wget gnupg build-essential curl erlang-base gcc-arm-linux-gnueabihf libncurses-dev:armhf libssl-dev:armhf unzip
