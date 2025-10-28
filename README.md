# RTW88 WiFi Drivers for Android 🚀

<div align="center">

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Kernel](https://img.shields.io/badge/kernel-4.x%20%7C%205.x-orange.svg)
![Architecture](https://img.shields.io/badge/arch-ARM64-green.svg)
![Status](https://img.shields.io/badge/build-passing-brightgreen.svg)

**Realtek RTW88 WiFi Driver Suite - Android Kernel Compatible**

*Pre-patched and ready to build for Android devices running Linux 4.x/5.x kernels*

[Features](#-features) • [Supported Hardware](#-supported-hardware) • [Building](#-building) • [Installation](#-installation) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Overview

This repository contains the **RTW88** WiFi driver suite from the Linux kernel mainline, specially patched and configured for **Android devices**. These drivers support modern Realtek WiFi chipsets with **5 GHz capability** and multiple bus interfaces (SDIO, USB, PCI).

### Why This Repository?

The upstream RTW88 drivers use newer kernel APIs that aren't always available in Android kernel trees. This repo provides:

- ✅ **Ready-to-build** drivers for Android kernels (4.x/5.x)
- ✅ **Backward compatibility** patches for older kernel APIs
- ✅ **Complete SDIO/USB/PCI** interface support
- ✅ **Pre-configured** Makefile for Android toolchains
- ✅ **25+ kernel modules** for various Realtek chipsets

---

## ✨ Features

- 🌐 **Dual-band WiFi** (2.4 GHz + 5 GHz)
- 📡 **802.11a/b/g/n/ac** support
- 🔌 **Multiple interfaces:** SDIO, USB, PCI/PCIe
- 🎯 **Monitor mode** capable (depends on chipset)
- 🔧 **DebugFS** interface for advanced debugging
- 💡 **LED control** support
- 🐧 **mac80211** wireless subsystem integration
- 📊 **WPA/WPA2/WPA3** encryption support

---

## 🔧 Supported Hardware

### Chipsets Supported

| Chipset Family | Models | Interface Types |
|---------------|--------|-----------------|
| **RTL8703** | RTL8703B | SDIO |
| **RTL8723** | RTL8723CS, RTL8723D, RTL8723DS, RTL8723DU | SDIO, USB |
| **RTL8812** | RTL8812A, RTL8812AU | USB |
| **RTL8814** | RTL8814A, RTL8814AE, RTL8814AU | PCI, USB |
| **RTL8821** | RTL8821A, RTL8821AU, RTL8821C, RTL8821CE, RTL8821CS, RTL8821CU | PCI, SDIO, USB |
| **RTL8822** | RTL8822B, RTL8822BE, RTL8822BS, RTL8822BU, RTL8822C, RTL8822CE, RTL8822CS, RTL8822CU | PCI, SDIO, USB |

### Bus Interface Support

- **SDIO** - SD card interface (common in embedded/mobile devices)
- **USB** - USB WiFi adapters
- **PCI/PCIe** - PCI Express (desktop/laptop cards)

---

## 📦 What's Included

### Kernel Modules (25 total)

#### Core Module
- `rtw_core.ko` - Main driver core (8.2 MB)

#### Bus Interfaces
- `rtw_sdio.ko` - SDIO interface support
- `rtw_usb.ko` - USB interface support
- `rtw_pci.ko` - PCI interface support

#### Chipset Drivers
All chipset-specific modules for RTL8703B, RTL8723 series, RTL8812/8814/8821/8822 series

---

## 🛠️ Building

### Prerequisites

1. **Android kernel source tree** (configured and prepared)
2. **ARM64 cross-compilation toolchain**
3. **Clang/LLVM** (for modern Android kernels)
4. **GCC cross-compiler** (for linking)

### Environment Setup

Export these environment variables (adjust paths to match your system):
```bash
export ARCH=arm64
export SUBARCH=arm64
export CC=~/toolchains/android_prebuilts_clang_host_linux-x86_clang-r416183b/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=~/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export HOSTCC=gcc-12
export HOSTCXX=g++-12
```

### Build Configuration

Edit the `Makefile` to match your environment:
```makefile
# Kernel configuration
KVER ?= $(shell uname -r)
KSRC ?= /path/to/your/android/kernel/source
KBUILD_OUTPUT ?= $(KSRC)/out

# Android paths (for installation)
ANDROID_PRODUCT_OUT ?= /path/to/android/out/target/product/yourdevice
```

### Compile Drivers
```bash
# Clone this repository
git clone https://github.com/ShorterKing/RTW88-Android-Drivers.git
cd RTW88-Android-Drivers

# Show current configuration
make config

# Build all modules
make -j$(nproc)

# Check built modules
ls -lh *.ko
```

### Build Targets
```bash
make              # Build all modules
make clean        # Clean build artifacts
make prepare      # Prepare kernel headers
make config       # Show current configuration
make install      # Install to Android product output
make install_fw   # Install firmware files
make install_device # Push directly to device via ADB
```

---

## 📲 Installation

### Method 1: Manual Installation (Recommended)
```bash
# Enable root and remount system
adb root
adb remount

# Create directories
adb shell mkdir -p /vendor/lib/modules
adb shell mkdir -p /vendor/firmware/rtw88

# Push modules
adb push *.ko /vendor/lib/modules/

# Push firmware (if available)
adb push firmware/*.bin /vendor/firmware/rtw88/

# Reboot device
adb reboot
```

### Method 2: Automated Installation
```bash
# Install directly to connected device
make install_device
```

### Method 3: Include in ROM Build

Copy modules to your Android build tree:
```bash
# Copy to vendor modules
cp *.ko $ANDROID_PRODUCT_OUT/vendor/lib/modules/

# Copy firmware
cp firmware/*.bin $ANDROID_PRODUCT_OUT/vendor/firmware/rtw88/
```

---

## 🔌 Loading Modules

Modules must be loaded in the correct order:
```bash
# 1. Load core module first
insmod /vendor/lib/modules/rtw_core.ko

# 2. Load bus interface (choose one)
insmod /vendor/lib/modules/rtw_sdio.ko   # For SDIO devices
# OR
insmod /vendor/lib/modules/rtw_usb.ko    # For USB devices
# OR  
insmod /vendor/lib/modules/rtw_pci.ko    # For PCI devices

# 3. Load chipset module (example for RTL8821CU)
insmod /vendor/lib/modules/rtw_8821c.ko
insmod /vendor/lib/modules/rtw_8821cu.ko
```

### Automatic Loading

Create a module loading script at `/vendor/etc/init/rtw88-wifi.rc`:
```rc
on boot
    insmod /vendor/lib/modules/rtw_core.ko
    insmod /vendor/lib/modules/rtw_usb.ko
    insmod /vendor/lib/modules/rtw_8821c.ko
    insmod /vendor/lib/modules/rtw_8821cu.ko
```

---

## 🔍 Verification

### Check Module Loading
```bash
# List loaded modules
lsmod | grep rtw

# Check dmesg for driver messages
dmesg | grep rtw88

# Verify WiFi interface
ip link show
# OR
ifconfig -a
```

### Check Module Info
```bash
modinfo /vendor/lib/modules/rtw_core.ko
```

---

## 🐛 Troubleshooting

### Module Won't Load

**Error:** `Invalid module format` or `Unknown symbol`

**Solution:**
1. Ensure kernel version matches (check with `uname -r`)
2. Rebuild modules with correct kernel source
3. Check module dependencies with `modinfo`

### Firmware Not Found

**Error:** `rtw88: firmware request failed`

**Solution:**
1. Verify firmware files are in `/vendor/firmware/rtw88/`
2. Check SELinux permissions: `restorecon -R /vendor/firmware/rtw88`
3. Download firmware from [linux-firmware repository](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git)

### WiFi Interface Not Appearing

**Solution:**
1. Check if modules loaded: `lsmod | grep rtw`
2. Check dmesg for errors: `dmesg | grep -i rtw`
3. Verify hardware is detected: `lsusb` or `lspci`
4. Try unloading and reloading modules in correct order

### Build Errors

**Error:** `__nonstring undeclared` or `RX_FLAG_NO_PSDU undeclared`

**Solution:** This repo is already patched! If you see this, you might have the wrong branch. Use the `main` branch.

---

## 📝 Compatibility Notes

### Tested Kernels
- ✅ Linux 4.14 (Android common kernel)
- ✅ Linux 4.19 (GKI base)
- ✅ Linux 5.4 (LTS)
- ✅ Linux 5.10 (LTS)

### Known Limitations
- PCI modules require `CONFIG_PCI=y` in kernel config
- SDIO modules require `CONFIG_MMC` support
- Some chipsets may require additional firmware files

---

## 📚 Documentation

- [Changelog](CHANGELOG.md) - Detailed change history and patch descriptions
- [Android Kernel Docs](https://source.android.com/docs/core/architecture/kernel) - Android kernel guide

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Report bugs** - Open an issue with device details and logs
2. **Test on new devices** - Share compatibility results
3. **Improve patches** - Submit PRs with better compatibility fixes
4. **Add firmware** - Help locate and document required firmware files
5. **Documentation** - Improve setup instructions

### Contribution Guidelines

- Test changes on real hardware before submitting
- Maintain compatibility with both old and new kernels
- Keep patches minimal and well-documented
- Follow kernel coding style

---

## ⚖️ License

This project maintains the original driver licenses:

- **Driver code:** GPL-2.0 OR BSD-3-Clause
- **Build scripts:** GPL-3.0 (this repository)

See [LICENSE](LICENSE) for full details.

---

## 🙏 Credits

- **Upstream RTW88 drivers** - Linux kernel wireless maintainers
- **Realtek** - Original driver development
- **Android kernel team** - Kernel infrastructure
- **Community contributors** - Testing and bug reports

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/ShorterKing/RTW88-Android-Drivers/issues)
- **Discussions:** Use GitHub Discussions for questions
---

## 🌟 Star History

If this project helped you, consider giving it a ⭐ star!

---

<div align="center">

**Built with ❤️ for the Android modding community**

[Report Bug](https://github.com/ShorterKing/RTW88-Android-Drivers/issues) • [Request Feature](https://github.com/ShorterKing/RTW88-Android-Drivers/issues) • [Contribute](https://github.com/ShorterKing/RTW88-Android-Drivers/pulls)

</div>
