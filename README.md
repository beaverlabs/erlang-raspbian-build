# Erlang Cross-Compiled Build Script for Raspberry Pi

Bash script for creating a small Erlang release targeting Raspberry Pi (armhf).
The goal is to keep the package as small as possible by stripping the release of
unnecessary things.

This relies on cross-compilation to target armhf, allowing the build script to
be run on a x86 development machine for example.

Example:

`$ ./minimal_erlang.sh 22.3`

The script will download and unpack the Erlang/OTP source tarball and build a
Erlang release from source. It will then build a basic Debian package for installation.

See http://www.erlang.org/doc/installation_guide/INSTALL.html
