# Live MCQ™ Desktop for Linux

[![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)](https://github.com/sadabx/livemcq-linux)
[![Wine](https://img.shields.io/badge/Powered%20by-Wine-722F37?logo=wine&logoColor=white)](https://winehq.org)
[![Flutter](https://img.shields.io/badge/Engine-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

A seamless, native-feeling Linux launcher for the official **[Live MCQ™](https://livemcq.com)** desktop application (developed by CrackTech Limited).

Live MCQ's Windows application is built on the portable **Flutter desktop engine**. This wrapper packages the official client with native desktop shortcuts and high-resolution icons, allowing Linux users to study without running sluggish or overzoomed Android emulators/Waydroid.

---

## ✨ Features

* **Complete Exam Catalog:** Access all scheduled live model tests, archive question banks, and sub-categories present in the desktop version.
* **Sharp Display & Proper Scaling:** Renders at your screen's true DPI without the blurry, overzoomed interface typical of mobile emulators.
* **Seamless Desktop Integration:** Appears in your application launcher (GNOME, KDE, App Launcher, Rofi) with the official 256x256 icon.
* **Zero System Bloat:** Installs cleanly into your user directory (`~/.local/share/LiveMCQ`) without requiring `sudo` privileges.

---

## 📋 Prerequisites

Before installing, ensure **Wine** (version 7.0 or newer) is installed on your Linux system:

### Arch Linux / Manjaro
```bash
sudo pacman -S wine
```

### Ubuntu / Debian / Linux Mint
```bash
sudo apt update && sudo apt install wine
```

### Fedora
```bash
sudo dnf install wine
```

---

## 📦 Option A: Portable AppImage (No Installation Needed)

The simplest way to run Live MCQ on any Linux distribution without installing anything:

1. Download **[`LiveMCQ-x86_64.AppImage`](https://github.com/sadabx/livemcq-linux/releases/latest/download/LiveMCQ-x86_64.AppImage)** from [Releases](https://github.com/sadabx/livemcq-linux/releases).
2. Make it executable:
   ```bash
   chmod +x LiveMCQ-x86_64.AppImage
   ```
3. Double-click it to run, or launch from terminal:
   ```bash
   ./LiveMCQ-x86_64.AppImage
   ```

---

## 🚀 Option B: 1-Line Desktop Installation

If you prefer Live MCQ installed into your system app launcher menu (GNOME/KDE) with permanent shortcuts:

```bash
curl -fsSL https://raw.githubusercontent.com/sadabx/livemcq-linux/main/install.sh | bash
```

The script will automatically:
1. Verify your Wine installation.
2. Download the pre-packaged app bundle.
3. Install the app to `~/.local/share/LiveMCQ/`.
4. Register the desktop launcher and icon.

---

## 🖥️ How to Launch

* **From Application Launcher:** Search for **"Live MCQ"** in your system menu.
* **From Terminal:**
  ```bash
  ~/.local/bin/livemcq
  ```

---

## 🗑️ Uninstallation

To remove Live MCQ and all its shortcuts completely, run:

```bash
curl -fsSL https://raw.githubusercontent.com/sadabx/livemcq-linux/main/uninstall.sh | bash
```

---

## 🛠️ For Maintainers / Updating Versions

To package a new `.Msix` release from Microsoft Store:
1. Extract the `.Msix` archive using `7z x <package>.Msix -oLiveMCQ_Windows`.
2. Run the packaging script:
   ```bash
   ./build-release.sh ./LiveMCQ_Windows
   ```
3. Attach `dist/livemcq-linux-x64.tar.gz` to a new release on GitHub.

---

### Disclaimer
*This project is an unofficial open-source wrapper enabling GNU/Linux users to run the official Live MCQ desktop application. All application assets, backend services, and logos belong to CrackTech Limited, Bangladesh.*
