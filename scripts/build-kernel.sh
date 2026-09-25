#!/usr/bin/env bash
# Build the Samsung A217F kernel (exynos3830) with AOSP clang + GCC cross toolchain.
#
# Usage:
#   ./scripts/build-kernel.sh /path/to/samsung-fullbuild-a217f

set -euxo pipefail

KERNEL_DIR="${1:?Usage: $0 /path/to/samsung-fullbuild-a217f}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "${SCRIPT_DIR}/env.sh"

cd "${KERNEL_DIR}"

make ARCH=arm64 \
  CC="${CC}" \
  CLANG_TRIPLE="${CLANG_TRIPLE}" \
  CROSS_COMPILE="${CROSS_COMPILE}" \
  exynos3830-a217f_defconfig

make ARCH=arm64 \
  CC="${CC}" \
  CLANG_TRIPLE="${CLANG_TRIPLE}" \
  CROSS_COMPILE="${CROSS_COMPILE}" \
  KCFLAGS="-Wno-unknown-warning-option -Wno-error" \
  EXTRA_CFLAGS="-Wno-unknown-warning-option -Wno-error" \
  -j"$(nproc)"

echo "----------------------------------------"
echo "Build artifacts:"
ls -la arch/arm64/boot/Image
ls -la Module.symvers
ls -la vmlinux
