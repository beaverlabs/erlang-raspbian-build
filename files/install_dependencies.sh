#!/bin/bash

set -e

dpkg --add-architecture armhf
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
dpkg -i erlang-solutions_2.0_all.deb
rm erlang-solutions_2.0_all.deb
apt update
apt install build-essential curl erlang-base gcc-arm-linux-gnueabihf libncurses-dev:armhf libssl-dev:armhf unzip wget --no-install-recommends -y
