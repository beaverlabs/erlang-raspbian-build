# Erlang and Elixir build scripts for Raspberry Pi

This repository contains a set of scripts to build minimal Erlang and Elixir Debian
packages targeting the Raspberry Pi platform.

The erlang script leverages cross-compilation to target armhf, allowing the build
script to be run on a fast x86 development machine. We then strip
binaries and remove unnecessary files to make a minimal, lightweight erlang release.

## Requirements

To simplify the build process, we use Docker containers.

You may choose to use the build scripts available in `./files/` directly without
containers, in that case please read the relevant section below.

## Usage

First we setup the container:

`$ ./setup.sh`

This will build a new container image based on Debian Buster, copy a few files
and install the required dependencies to build erlang.

We can then run the desired build script:

```
$ ./build.sh erlang 22.3
$ ./build.sh elixir 1.10.2
```

The generated `.deb` files will be available in `$PWD/shared/debs/` on the
host.

Once you are done and would like to remove the container image:

```
$ ./teardown.sh destroy # Removes the container image
```

## Using build scripts directly (without containers)

Build scripts may be used directly provided you have the required dependencies
and run them in a Debian-like environment. You may read `./files/install_dependencies.sh`
to learn about dependencies required to build erlang and `./files/build_erlang_deb.sh`
to learn about the erlang build process.

See http://www.erlang.org/doc/installation_guide/INSTALL.html

## Acknowledgements

The erlang build script is a fork of https://github.com/Gustav-Simonsson/Stripped-Erlang
