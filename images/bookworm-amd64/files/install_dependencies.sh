#!/bin/bash

set -e

apt update && apt install --no-install-recommends -y ca-certificates wget gnupg build-essential curl erlang-base libncurses-dev libssl-dev unzip
