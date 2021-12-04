#!/bin/bash

# Forked from https://github.com/Gustav-Simonsson/Stripped-Erlang

set -e

if [[ -z "$1" ]]; then
  echo "usage: ./build_erlang_deb.sh <release>"
  exit 1;
fi

# 1. Download the erlang source code
SE_ERLANG_RELEASE=$1
SE_SHARED_DIR=/mnt/shared
SE_DEB_DIR=$SE_SHARED_DIR/debs
SE_DOWNLOAD_DIR=$SE_SHARED_DIR/downloads/erlang
mkdir -p $SE_DOWNLOAD_DIR $SE_DEB_DIR
SE_RELEASE_DIR=erlang-$SE_ERLANG_RELEASE
SE_ERLANG_SOURCE_FILE="$SE_DOWNLOAD_DIR/otp_src_$SE_ERLANG_RELEASE.tar.gz"

if [[ -f "$SE_ERLANG_SOURCE_FILE" ]]; then
  EXPECTED_MD5SUM=$(curl -Ls https://github.com/erlang/otp/releases/download/OTP-$SE_ERLANG_RELEASE/MD5.txt | grep "otp_src_$SE_ERLANG_RELEASE.tar.gz" | awk '{print$1}')
  ACTUAL_MD5SUM=$(md5sum $SE_ERLANG_SOURCE_FILE | awk '{print$1}')

  if [[ "$EXPECTED_MD5SUM" == "$ACTUAL_MD5SUM" ]]; then
    echo "$SE_ERLANG_SOURCE_FILE exists, not downloading"
  else
    echo "$SE_ERLANG_SOURCE_FILE exists but has wrong checksum! Actual: $ACTUAL_MD5SUM Expected: $EXPECTED_MD5SUM"
    exit 1
  fi
else
  wget -O $SE_ERLANG_SOURCE_FILE "https://github.com/erlang/otp/releases/download/OTP-$SE_ERLANG_RELEASE/otp_src_$SE_ERLANG_RELEASE.tar.gz"
fi

# 2. Create a directory for building and configuration of Erlang release and unpack source.
SE_TIMESTAMP=`date +%F_%H%M%S`
SE_BUILD_DIR=/stripped_erlang_$SE_TIMESTAMP
echo "Making build dir ${SE_BUILD_DIR}"
mkdir -p $SE_BUILD_DIR
echo "Unpacking source and moving into dir.."
tar xfz $SE_ERLANG_SOURCE_FILE -C $SE_BUILD_DIR

# 3. Enter directory and build the source.
SE_OTP_SOURCE_DIR_NAME=`tar -tf ${SE_ERLANG_SOURCE_FILE} | grep -o '^[^/]\+' | sort -u`
cd $SE_BUILD_DIR
mkdir $SE_RELEASE_DIR
SE_BUILD_DIR_ABS=$PWD
SE_OTP_SOURCE_DIR_ABS=$SE_BUILD_DIR_ABS/$SE_OTP_SOURCE_DIR_NAME
cd $SE_OTP_SOURCE_DIR_ABS

export ERL_TOP=$SE_OTP_SOURCE_DIR_ABS
./configure --enable-bootstrap-only
make -j8
./configure CFLAGS="-Os" --host=arm-linux-gnueabihf --build=x86_64-linux-gnu erl_xcomp_sysroot=/ \
  --with-ssl=/usr --with-ssl-incl=/usr --with-ssl-lib-subdir=/usr/lib/arm-linux-gnueabihf/
make -j8
make -j8 RELEASE_ROOT=$SE_BUILD_DIR_ABS/$SE_RELEASE_DIR release

# 4. Strip beams
erl -eval "beam_lib:strip_release('$SE_BUILD_DIR_ABS/$SE_RELEASE_DIR')" -s init stop > /dev/null
cd $SE_BUILD_DIR_ABS/$SE_RELEASE_DIR

# 5. Strip binaries (using correct tool chain)
arm-linux-gnueabihf-strip erts-*/bin/{beam.smp,ct_run,dialyzer,dyn_erl,epmd,erl_child_setup,erlc,erlc,erlexec,escript,heart,inet_gethost,run_erl,to_erl,typer}

# 6. Remove crap (src, include, doc etc.)
echo "Removing unnecessary files and directories"
rm -rf usr/
rm -rf misc/
for SE_DIR in erts* lib/*; do
    rm -rf ${SE_DIR}/doc
    rm -rf ${SE_DIR}/man
    rm -rf ${SE_DIR}/examples
    rm -rf ${SE_DIR}/emacs
    # Comment out next three lines to keep header files
    rm -rf ${SE_DIR}/c_src
    rm -rf ${SE_DIR}/src
    rm -rf ${SE_DIR}/include
done
# Comment out to keep header files
rm -rf erts-*/lib/
echo "Build ready."

# 9. Create .deb package

cd ../..
SE_DEB_PREFIX=erlang_$SE_ERLANG_RELEASE-1_armhf
mkdir -p $SE_DEB_PREFIX/usr/lib/erlang
mkdir -p $SE_DEB_PREFIX/usr/bin
mkdir -p $SE_DEB_PREFIX/DEBIAN
cp -r $SE_BUILD_DIR/$SE_RELEASE_DIR/* $SE_DEB_PREFIX/usr/lib/erlang
rm -rf $SE_BUILD_DIR

tee $SE_DEB_PREFIX/DEBIAN/control <<EOF
Package: erlang
Version: 1:$SE_ERLANG_RELEASE-1
Section: interpreters
Priority: optional
Architecture: armhf
Maintainer: Beaverlabs Team <support@beaverlabs.net>
Description: Erlang OTP $SE_ERLANG_RELEASE for Raspbian
EOF

tee $SE_DEB_PREFIX/DEBIAN/postinst <<EOF
#!/bin/sh
set -e
if [ "\$1" = "configure" ]; then
  /usr/lib/erlang/Install -sasl /usr/lib/erlang
  rm /usr/lib/erlang/Install
fi
EOF

chmod +x $SE_DEB_PREFIX/DEBIAN/postinst

ln -s ../lib/erlang/bin/epmd $SE_DEB_PREFIX/usr/bin/epmd
ln -s ../lib/erlang/bin/erl $SE_DEB_PREFIX/usr/bin/erl
ln -s ../lib/erlang/bin/erlc $SE_DEB_PREFIX/usr/bin/erlc
ln -s ../lib/erlang/lib/erl_interface-3.13.2/bin/erl_call $SE_DEB_PREFIX/usr/bin/erl_call
ln -s ../lib/erlang/bin/escript $SE_DEB_PREFIX/usr/bin/escript
ln -s ../lib/erlang/bin/run_erl $SE_DEB_PREFIX/usr/bin/run_erl
ln -s ../lib/erlang/bin/start $SE_DEB_PREFIX/usr/bin/start_embedded
ln -s ../lib/erlang/bin/to_erl $SE_DEB_PREFIX/usr/bin/to_erl

dpkg-deb --build $SE_DEB_PREFIX
rm -rf $SE_DEB_PREFIX

mv /erlang_$SE_ERLANG_RELEASE-1_armhf.deb $SE_DEB_DIR

echo "Done."
