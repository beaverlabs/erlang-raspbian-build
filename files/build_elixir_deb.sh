#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "usage: ./build_elixir_deb.sh <release>"
  exit 1;
fi

# 1. Download the elixir release
SE_ELIXIR_RELEASE=$1
SE_RELEASE_DIR=elixir-$SE_ELIXIR_RELEASE
SE_ELIXIR_RELEASE_FILE="/tmp/elixir_release_$SE_ELIXIR_RELEASE.zip"

if [[ ! -f "$SE_ELIXIR_RELEASE_FILE" ]]; then
  wget -O $SE_ELIXIR_RELEASE_FILE "https://github.com/elixir-lang/elixir/releases/download/v$SE_ELIXIR_RELEASE/Precompiled.zip"
fi

# 2. Create .deb package
SE_DEB_PREFIX=elixir_$SE_ELIXIR_RELEASE-1_all
mkdir -p $SE_DEB_PREFIX/usr/lib/elixir
mkdir -p $SE_DEB_PREFIX/usr/bin
mkdir -p $SE_DEB_PREFIX/DEBIAN

unzip $SE_ELIXIR_RELEASE_FILE -d $SE_DEB_PREFIX/usr/lib/elixir

rm -r $SE_DEB_PREFIX/usr/lib/elixir/man

tee $SE_DEB_PREFIX/DEBIAN/control <<EOF
Package: elixir
Version: 1:$SE_ELIXIR_RELEASE-1
Section: interpreters
Priority: optional
Architecture: all
Maintainer: Beaverlabs Team <support@beaverlabs.net>
Description: Elixir $SE_ELIXIR_RELEASE for Raspbian
EOF

ln -s ../lib/elixir/bin/elixir $SE_DEB_PREFIX/usr/bin/elixir
ln -s ../lib/elixir/bin/elixirc $SE_DEB_PREFIX/usr/bin/elixirc
ln -s ../lib/elixir/bin/iex $SE_DEB_PREFIX/usr/bin/iex
ln -s ../lib/elixir/bin/mix $SE_DEB_PREFIX/usr/bin/mix

dpkg-deb --build $SE_DEB_PREFIX
rm -rf $SE_DEB_PREFIX

echo "Done."
