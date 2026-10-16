# Live MCQ Desktop for Linux

[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)](https://github.com/sadabx/livemcq-linux)
[![Runtime: Wine](https://img.shields.io/badge/Runtime-Wine%207.0+-722F37?logo=wine&logoColor=white)](https://winehq.org)
[![Engine: Flutter](https://img.shields.io/badge/Engine-Flutter%20Desktop-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Architecture: x86_64](https://img.shields.io/badge/Architecture-x86__64-555555)](#prerequisites)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/sadabx/livemcq-linux?color=success)](https://github.com/sadabx/livemcq-linux/releases)

A native-feeling, high-performance Linux desktop wrapper and launcher for the official **[Live MCQ](https://livemcq.com)** exam preparation application (developed by CrackTech Limited).

---

## Table of Contents

- [Overview](#overview)
- [Why Native Wine Wrapper Over Emulators?](#why-native-wine-wrapper-over-emulators)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Option 1: Portable AppImage (Recommended)](#option-1-portable-appimage-recommended)
  - [Option 2: Automated Desktop Installer](#option-2-automated-desktop-installer)
  - [Option 3: Manual Installation](#option-3-manual-installation)
- [Usage](#usage)
- [Display and HiDPI Scaling](#display-and-hidpi-scaling)
- [Uninstallation](#uninstallation)
- [Maintainer Guide](#maintainer-guide)
- [Legal Disclaimer](#legal-disclaimer)
- [License](#license)

---

## Overview

Live MCQ is Bangladesh's premier competitive examination preparation platform, serving candidates preparing for BCS, Primary, Bank, Bar Council, and other government job exams.

While an official Windows desktop client is published via the **[Microsoft Store](https://apps.microsoft.com/detail/9pbq3mcgwzmm)**, Linux users often resort to heavy Android emulators or Waydroid setups. However, the Windows application is built upon Google's portable **Flutter Desktop Engine**.

This repository provides an optimized, native Linux execution environment that runs the official Windows binary via Wine. It eliminates the overhead of virtualization, ensures pixel-perfect font rendering for Bengali typography, and integrates seamlessly into Linux desktop application menus (GNOME, KDE Plasma, XFCE, and tiling window managers).

---

## Why Native Wine Wrapper Over Emulators?

| Feature / Metric | Live MCQ for Linux (This Wrapper) | Android Emulators / Waydroid |
| :--- | :--- | :--- |
| **RAM Utilization** | ~120 MB - 160 MB | 2.5 GB - 5.0 GB+ |
| **Startup Latency** | Under 2 seconds | 25 to 60 seconds |
| **DPI & Font Clarity** | True 1:1 display DPI; crisp Bengali fonts | Blurry upscaling; mobile aspect ratio |
| **Desktop Integration** | Native application menu, dock, and tray | Nested window / isolated mobile container |
| **CPU & Battery Impact** | Minimal idle usage | High virtualization overhead |
| **Privileges Required** | Runs entirely in user space (no root needed) | Often requires root, kernel modules, or Android images |

---

## Key Features

- **Full Catalog Access:** Complete access to scheduled live model tests, question banks, archive exams, study routines, and sub-categories.
- **Hardware-Accelerated Rendering:** Leverages Flutter's native desktop renderer for fluid transitions, instant question rendering, and fast response times.
- **Bengali Typography Support:** Bundled fonts render complex Bengali ligatures cleanly without missing glyphs.
- **Desktop Environment Integration:** Registers a standard Freedesktop `.desktop` entry, terminal command (`livemcq`), and official high-resolution application icons.
- **Isolated User Space:** Deploys cleanly into `~/.local/share/LiveMCQ` without modifying system files or requiring administrative (`sudo`) rights.

---

## Prerequisites

The only host requirement is **Wine** (version 7.0 or newer). Install it using your distribution's package manager:

### Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
sudo apt update && sudo apt install wine
```

### Arch Linux / Manjaro / EndeavourOS
```bash
sudo pacman -S wine
```

### Fedora / RHEL
```bash
sudo dnf install wine
```

### openSUSE
```bash
sudo zypper install wine
```

---

## Installation

Choose the deployment method that fits your workflow.

### Option 1: Portable AppImage (Recommended)

The AppImage package requires no installation and runs out-of-the-box on any modern Linux distribution:

1. Download [`LiveMCQ-x86_64.AppImage`](https://github.com/sadabx/livemcq-linux/releases/latest/download/LiveMCQ-x86_64.AppImage) from the [Releases](https://github.com/sadabx/livemcq-linux/releases) page.
2. Grant execution permissions:
   ```bash
   chmod +x LiveMCQ-x86_64.AppImage
   ```
3. Run the application:
   ```bash
   ./LiveMCQ-x86_64.AppImage
   ```

### Option 2: Automated Desktop Installer

If you want Live MCQ registered in your desktop application launcher (GNOME, KDE, Rofi, etc.) with persistent shortcuts:

```bash
curl -fsSL https://raw.githubusercontent.com/sadabx/livemcq-linux/main/install.sh | bash
```

The script automatically:
1. Verifies the local Wine runtime.
2. Downloads and extracts the application package into `~/.local/share/LiveMCQ`.
3. Configures an isolated Wine environment.
4. Installs the high-resolution application icon to standard icon directories.
5. Registers the desktop launcher and `livemcq` terminal binary in `~/.local/bin`.

### Option 3: Manual Installation

If operating in an air-gapped system or compiling from local assets:

1. Clone this repository:
   ```bash
   git clone https://github.com/sadabx/livemcq-linux.git
   cd livemcq-linux
   ```
2. Run the local installer:
   ```bash
   ./install.sh
   ```

---

## Usage

### From Application Launcher
Open your application menu or launcher (Super key / Application Menu) and search for **Live MCQ**.

### From Command Line
Run the launcher directly from any terminal session:
```bash
livemcq
```

*(Ensure `~/.local/bin` is present in your shell's `$PATH` variable).*

---

## Display and HiDPI Scaling

If you are using a 2K, 4K, or high-density display and wish to adjust font or UI scaling:

1. Open the Wine configuration utility for Live MCQ's prefix:
   ```bash
   WINEPREFIX="$HOME/.local/share/LiveMCQ/wineprefix" winecfg
   ```
2. Navigate to the **Graphics** tab.
3. Adjust the **Screen resolution** (DPI) slider (default is 96 DPI; set to 120 or 144 DPI for HiDPI displays).
4. Click **Apply** and restart Live MCQ.

---

## Uninstallation

To cleanly remove Live MCQ, including all associated binaries, icons, and desktop entries:

```bash
curl -fsSL https://raw.githubusercontent.com/sadabx/livemcq-linux/main/uninstall.sh | bash
```

To also remove stored application caches and prefix configuration data, append the `--purge` flag:

```bash
curl -fsSL https://raw.githubusercontent.com/sadabx/livemcq-linux/main/uninstall.sh | bash -s -- --purge
```

---

## Maintainer Guide

To update the release archive or build a new AppImage when CrackTech Limited publishes a new release on the [Microsoft Store](https://apps.microsoft.com/detail/9pbq3mcgwzmm?ocid=webpdpshare):

### 1. Build Release Archive
Place the latest `.Msix` file in the repository root (or pass path to an extracted directory):
```bash
./build-release.sh
```
The script will auto-extract the package and produce `dist/livemcq-linux-x64.tar.gz`.

### 2. Build Standalone AppImage
```bash
./build-appimage.sh
```
The standalone AppImage will be output to `dist/LiveMCQ-x86_64.AppImage`.

---

## Legal Disclaimer

Live MCQ is a registered product and trademark of CrackTech Limited, Bangladesh.

This repository provides an unofficial, community-maintained compatibility wrapper and desktop integration utility for GNU/Linux environments. It does not alter application binaries, bypass subscription requirements, or redistribute proprietary backend services. All application content, trademarks, logos, and services remain the sole property of CrackTech Limited.

---

## License

The wrapper scripts, desktop integration assets, and packaging utilities in this repository are licensed under the [MIT License](LICENSE).
