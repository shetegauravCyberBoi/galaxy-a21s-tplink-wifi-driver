# a21s-88x2bu-driver

Out-of-tree **88x2bu** (RTL8812BU / RTL8821BU) USB Wi-Fi driver, cross-compiled for a **rooted Samsung Galaxy A21s (SM-A217F)** against Samsung's official open-source kernel and the AOSP Clang toolchain.

> ⚠️ This is an unofficial, community build for a rooted device. Flashing/rooting voids your warranty. Use at your own risk.

---

## Device info

| Field | Value |
|---|---|
| Device | Samsung Galaxy A21s |
| Model | SM-A217F |
| SoC | Exynos 3830 |
| Kernel version | 4.19.132-24202344 |
| Build ID | A217FXXSCDXE2 |
| Security patch | 2024-05-01 |
| Defconfig | `exynos3830-a217f_defconfig` |
| Architecture | aarch64 (arm64) |

<details>
<summary>Raw <code>adb</code> output</summary>

```
$ adb shell 'uname -a'
Linux kali 4.19.132-24202344 #1 SMP PREEMPT Tue May 14 14:47:01 +07 2024 aarch64

$ adb shell 'uname -r'
4.19.132-24202344

$ adb shell 'cat /proc/version'
Linux version 4.19.132-24202344 (dpi@VPDJR204) (Android (5484270 based on r353983c)
clang version 9.0.3 (https://android.googlesource.com/toolchain/clang
745b335211bb9eadfa6aa6301f84715cee4b37c5)
(https://android.googlesource.com/toolchain/llvm
60cf23e54e46c807513f7a36d0a7b777920b5881) (based on LLVM 9.0.3svn)) #1 SMP PREEMPT
Tue May 14 14:47:01 +07 2024

$ adb shell 'getprop ro.product.model'
SM-A217F

$ adb shell 'getprop ro.build.version.incremental'
A217FXXSCDXE2

$ adb shell 'getprop ro.build.version.security_patch'
2024-05-01
```

</details>

## Toolchain

| Component | Value |
|---|---|
| Clang | `r353983c` (clang-4691093) |
| Clang triple | `aarch64-linux-gnu-` |
| Cross compiler | `aarch64-linux-android-4.9` |
| Cross compile prefix | `aarch64-linux-android-` |

Derived by grepping the kernel build config against the running kernel's `/proc/version` fingerprint:

```bash
grep -rhsE '^(CLANG_VERSION|CLANG_TRIPLE|CROSS_COMPILE) [:?+]?=' build.config Makefile
```

## Repo layout

```
a21s-88x2bu-driver/
├── README.md
├── LICENSE                 # GPL-2.0
├── docs/
│   └── device-info.md       # raw adb output, kept verbatim
├── scripts/
│   ├── env.sh                # exports PATH / toolchain vars
│   ├── build-kernel.sh
│   └── build-module.sh
└── patches/                 # any source patches needed for KSRC cross-compile
```

The full Samsung kernel source and the 88x2bu driver source are **not vendored in this repo** — they're pulled from their upstream locations at build time (see below). Only build scripts, patches, and documentation live here.

---

## 1. Get the sources

**Samsung kernel source** (must match your exact build ID / security patch):
- https://opensource.samsung.com/uploadSearch?searchValue=A217F
- Download the archive matching build `A217FXXSCDXE2` / patch level `2024-05-01`.

**88x2bu driver source:**
```bash
git clone https://github.com/morrownr/88x2bu-20210702.git
```

## 2. Set up the toolchain

```bash
git clone https://github.com/kclinx/android_prebuilts_clang_host_linux-x86_clang-r353983c.git \
  /opt/toolchains/aosp-clang/clang-r353983c

git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 \
  /opt/toolchains/aarch64-linux-android-4.9

export PATH="/opt/toolchains/aarch64-linux-android-4.9/bin:$PATH"
```

## 3. Build the kernel

```bash
cd samsung-fullbuild-a217f

make ARCH=arm64 \
  CC=/opt/toolchains/aosp-clang/clang-r353983c/bin/clang \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=aarch64-linux-android- \
  exynos3830-a217f_defconfig

make ARCH=arm64 \
  CC=/opt/toolchains/aosp-clang/clang-r353983c/bin/clang \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=aarch64-linux-android- \
  KCFLAGS="-Wno-unknown-warning-option -Wno-error" \
  EXTRA_CFLAGS="-Wno-unknown-warning-option -Wno-error" \
  -j"$(nproc)"
```

**Verify the build:**
```bash
ls -la arch/arm64/boot/Image
ls -la Module.symvers
ls -la vmlinux
```

## 4. Build the 88x2bu module

```bash
cd 88x2bu-20210702
make clean

make \
  ARCH=arm64 \
  CC=/opt/toolchains/aosp-clang/clang-r353983c/bin/clang \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=aarch64-linux-android- \
  KSRC=/path/to/samsung-fullbuild-a217f \
  KCFLAGS="-Wno-unknown-warning-option -Wno-parentheses-equality -Wno-error" \
  EXTRA_CFLAGS="-Wno-unknown-warning-option -Wno-parentheses-equality -Wno-error" \
  -j"$(nproc)"
```

This produces `88x2bu.ko`.

## 5. Install and verify on device

```bash
modinfo 88x2bu.ko

adb push 88x2bu.ko /data/local/tmp/
adb shell su -c "insmod /data/local/tmp/88x2bu.ko"
adb shell dmesg | tail -50
adb shell ip link
```

---

## Releases

Prebuilt `.ko` binaries are **not committed to this repo** — they're attached to [GitHub Releases](../../releases), tagged to the exact kernel build they were compiled against (e.g. `v1.0-A217FXXSCDXE2`). A module built against one security patch level is not guaranteed to load on another; check the release tag against your device's build ID before flashing.

## License

This project is licensed under the **GNU General Public License v2.0** — see [LICENSE](LICENSE).

The Linux kernel and the 88x2bu driver are both GPLv2. Samsung's kernel source is not redistributed here; it is linked to their official Open Source portal, which satisfies GPL source-distribution requirements independently.

## Credits

- [Samsung Open Source Release Center](https://opensource.samsung.com/) — official A217F kernel source
- [morrownr/88x2bu-20210702](https://github.com/morrownr/88x2bu-20210702) — 88x2bu driver source
- [kclinx/android_prebuilts_clang_host_linux-x86_clang-r353983c](https://github.com/kclinx/android_prebuilts_clang_host_linux-x86_clang-r353983c) — AOSP Clang toolchain mirror
- AOSP `aarch64-linux-android-4.9` prebuilt GCC toolchain

## Disclaimer

Rooting, flashing, and running out-of-tree kernel modules can brick your device, void your warranty, and introduce security risks. This repository is provided for educational and personal use only, with no warranty of any kind.
