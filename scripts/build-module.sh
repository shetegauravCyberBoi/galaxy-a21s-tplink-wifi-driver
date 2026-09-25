#!/usr/bin/env bash
# Build the 88x2bu out-of-tree Wi-Fi driver against the built A217F kernel tree.
#
# Usage:
#   ./scripts/build-module.sh /path/to/88x2bu-20210702 /path/to/samsung-fullbuild-a217f

set -euxo pipefail

MODULE_DIR="${1:?Usage: $0 /path/to/88x2bu-20210702 /path/to/samsung-fullbuild-a217f}"
KSRC="${2:?Usage: $0 /path/to/88x2bu-20210702 /path/to/samsung-fullbuild-a217f}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "${SCRIPT_DIR}/env.sh"

cd "${MODULE_DIR}"
make clean

make \
  ARCH=arm64 \
  CC="${CC}" \
  CLANG_TRIPLE="${CLANG_TRIPLE}" \
  CROSS_COMPILE="${CROSS_COMPILE}" \
  KSRC="${KSRC}" \
  KCFLAGS="-Wno-unknown-warning-option -Wno-parentheses-equality -Wno-error" \
  EXTRA_CFLAGS="-Wno-unknown-warning-option -Wno-parentheses-equality -Wno-error" \
  -j"$(nproc)"

echo "----------------------------------------"
echo "Module built:"
ls -la 88x2bu.ko
modinfo 88x2bu.ko
