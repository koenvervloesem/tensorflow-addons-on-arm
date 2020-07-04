#!/bin/bash
# Script to build TensorFlow Addons on Raspbian Buster

# Use the latest supported version if no argument has been specified
if [ -z "$1" ]; then
    VERSION=$(cat TFA_VERSION)
    echo "No version specified, using ${VERSION}"
else
    VERSION=$1
fi

TFA_DIR=addons-${VERSION}
TARBALL=addons-v${VERSION}.tar.gz
DOWNLOAD_URL=https://github.com/tensorflow/addons/archive/v${VERSION}.tar.gz
PATCH=patches/addons-"${VERSION}"-arm.patch

# Download and extract TensorFlow Addons 
if [ ! -f "${TARBALL}" ]; then
    wget -O "${TARBALL}" "${DOWNLOAD_URL}"
fi
if [ -d "${TFA_DIR}" ]; then
    rm -rf "${TFA_DIR}"
fi
tar xzf "${TARBALL}"

# Patch TensorFlow Addons if there's a patch for this version
if [ -f "${PATCH}" ]; then
    # Patch created with (for example):
    # $ diff -ruN addons-0.7.1 addons-0.7.1-2 > patches/addons-0.7.1-arm.patch 
    patch -s -p0 < "${PATCH}"
fi

# Configure and patch .bazelrc
cd "${TFA_DIR}" || exit
export TF_NEED_CUDA=0 # No GPU Custom Ops on Raspberry Pi
./configure.sh
TF_HEADER_DIR=$(grep -Po 'TF_HEADER_DIR="\K.*?(?=")' .bazelrc)
TF_SHARED_LIBRARY_DIR=${TF_HEADER_DIR/include/python}
sed -i "s|TF_SHARED_LIBRARY_DIR=\"\"|TF_SHARED_LIBRARY_DIR=\"${TF_SHARED_LIBRARY_DIR}\"|" .bazelrc
sed -i "s|TF_SHARED_LIBRARY_NAME=\"\"|TF_SHARED_LIBRARY_NAME=\"_pywrap_tensorflow_internal.so\"|" .bazelrc

# Build TensorFlow Addons and link to libatomic
bazel build --enable_runfiles --linkopt=-latomic build_pip_pkg
bazel-bin/build_pip_pkg artifacts
