#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT=${OUT:-out-droidspaces}
JOBS=${JOBS:-$(nproc)}

cd "$ROOT"
if [[ -n "${NEUTRON_CLANG_DIR:-}" ]]; then
  export PATH="${NEUTRON_CLANG_DIR}/bin:${PATH}"
fi
if ! command -v clang >/dev/null 2>&1; then
  echo 'clang not found; add Neutron Clang 24.0.0 to PATH or set NEUTRON_CLANG_DIR' >&2
  exit 1
fi
if ! clang --version | head -n1 | grep -q '24.0.0'; then
  echo 'This tested build configuration expects Neutron Clang 24.0.0' >&2
  clang --version | head -n1 >&2
  exit 1
fi

make O="$OUT" ARCH=arm64 LLVM=1 LLVM_IAS=1 vendor/whyred-perf_defconfig
"$ROOT/scripts/check-droidspaces-config.sh" "$OUT/.config"
make O="$OUT" ARCH=arm64 LLVM=1 LLVM_IAS=1 Image.gz-dtb -j"$JOBS"
echo "Built: $OUT/arch/arm64/boot/Image.gz-dtb"
make O="$OUT" ARCH=arm64 LLVM=1 LLVM_IAS=1 kernelrelease
