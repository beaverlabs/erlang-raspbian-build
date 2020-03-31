#!/bin/bash

set -e

if [ -z "$1" ]
then
  echo "usage: ./minimal_erlang.sh <release>"
  exit 1;
fi

# 1. Download the erlang source code
SE_ERLANG_RELEASE=$1
SE_RELEASE_DIR=$SE_ERLANG_RELEASE
SE_ERLANG_SOURCE_FILE="/tmp/otp_src_$SE_ERLANG_RELEASE.tar.gz"
SE_DO_BUILD=yes
SE_DEBUG_ENABLED=true

if [ -f "$SE_ERLANG_SOURCE_FILE" ]
then
  EXPECTED_MD5SUM=$(curl -s http://erlang.org/download/MD5 | grep "^MD5(otp_src_22.3.tar.gz)=" | awk -F =  '{gsub(/ /, "", $2); print$2}')
  ACTUAL_MD5SUM=$(md5sum $SE_ERLANG_SOURCE_FILE | awk '{print$1}')

  if [[ "$EXPECTED_MD5SUM" == "$ACTUAL_MD5SUM" ]]
  then
    echo "$SE_ERLANG_SOURCE_FILE exists, not downloading"
  else
    echo "$SE_ERLANG_SOURCE_FILE exists but has wrong checksum! Actual: $ACTUAL_MD5SUM Expected: $EXPECTED_MD5SUM"
    exit 1
  fi
else
  wget -O $SE_ERLANG_SOURCE_FILE "http://erlang.org/download/otp_src_$SE_ERLANG_RELEASE.tar.gz"
fi

# 2. Create a directory for building and configuration of Erlang release and unpack source.
SE_TIMESTAMP=`date +%F_%H%M%S`
SE_BUILD_DIR=stripped_erlang_$SE_TIMESTAMP
echo "Making build dir ${SE_BUILD_DIR}"
mkdir $SE_BUILD_DIR
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
./configure CFLAGS="-Os" --host=arm-linux-gnueabihf --build=x86_64-linux-gnu \
  erl_xcomp_sysroot=/ --with-ssl=/usr/include/arm-linux-gnueabihf/
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
    rm -rf ${SE_DIR}/src
    rm -rf ${SE_DIR}/include
    rm -rf ${SE_DIR}/doc
    rm -rf ${SE_DIR}/man
    rm -rf ${SE_DIR}/examples
    rm -rf ${SE_DIR}/emacs
    rm -rf ${SE_DIR}/c_src
done
rm -rf erts-*/lib/

# 9. Create installation archive
cd ../..
SE_TARBALL_PREFIX=minimal_erlang_$SE_OTP_SOURCE_DIR_NAME_$SE_TIMESTAMP
mkdir $SE_TARBALL_PREFIX
cp -r $SE_BUILD_DIR/$SE_RELEASE_DIR $SE_TARBALL_PREFIX/
echo "

Installation:

1. Unpack archive.
2. ./Install -minimal

" >> $SE_TARBALL_PREFIX/README

tar czf $SE_TARBALL_PREFIX.tar.gz $SE_TARBALL_PREFIX

if [ "$SE_DEBUG_ENABLED" != yes ]
then
    rm -rf $SE_BUILD_DIR
fi

echo "Done. Check README in $SE_TARBALL_PREFIX folder/tarball."

# TODO (on target system):
# 1. Unpack archive at preffered location (this will be $ERL_ROOT)
# 2. Run $ERL_ROOT/Install -minimal 

