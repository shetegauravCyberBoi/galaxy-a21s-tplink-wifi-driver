#!/usr/bin/env bash
# Toolchain environment setup for A21s (SM-A217F) kernel + module builds.
# Usage: source scripts/env.sh

set -euo pipefail

# --- Edit these paths if your toolchains live elsewhere ---
export TOOLCHAIN_ROOT="/opt/toolchains"
export CLANG_PATH="${TOOLCHAIN_ROOT}/aosp-clang/clang-r353983c"
export GCC_PATH="${TOOLCHAIN_ROOT}/aarch64-linux-android-4.9"

export PATH="${GCC_PATH}/bin:${PATH}"

export ARCH=arm64
export CC="${CLANG_PATH}/bin/clang"
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-

echo "Environment set:"
echo "  ARCH           = ${ARCH}"
echo "  CC             = ${CC}"
echo "  CLANG_TRIPLE   = ${CLANG_TRIPLE}"
echo "  CROSS_COMPILE  = ${CROSS_COMPILE}"
