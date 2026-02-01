# DTV-All-in-One Docker
A simple project to **automate source building, environment setup, and channel scanning** for DTV using **Docker**.

## Overview
This project provides a fully automated environment for DTV (Digital Television) enthusiasts. Using simple scripts, it builds all necessary components from source within "throwaway" containers and merges them into a single, optimized runtime image.

### Features
* **Full Automation:** Seamlessly handles everything from source compilation to environment deployment with a single script.
* **Smart Update:** Easily update all tools while preserving your existing EPG and recording data.
* **Docker-powered:** No need to mess with your host OS; everything runs in isolated containers.
* **Ready-to-use:** Includes automated channel scanning to get you started immediately.

## Integrated Tools
The following tools are automatically built and configured to work together:
* **Mirakurun:** Tuner server for ISDB.
* **EDCB:** Recording and EPG management.
* **EDCB_Material_WebUI:** A modern web interface for EDCB.
* **BonDriver_LinuxMirakc:** Bridge between Mirakurun and EDCB.
* **ISDBScanner:** Automated channel scanning utility.
* **recisdb-rs:** Recording command line tool (Rust implementation).
* **libaribb25:** ARIB STD-B25 decoding library.
* **KonomiTV:** Modern TV viewing web interface.

## Usage

### Prerequisites
* Docker / Docker Compose
* DTV Tuner drivers installed on the host machine.

### Initial Setup
Run the setup script suitable for your environment. This will build all tools and perform the initial configuration (including channel scanning) automatically.

**Windows:**
```powershell
.\setup.bat
```

**Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

### Updating Tools
To update all tools to their latest versions while keeping your EPG data and recording history intact:

**Windows:**
```powershell
.\update.bat
```

**Linux:**
```bash
./update.sh
```

## License & Credits

### Project License
This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.  
Due to the integration of **recisdb-rs (GPLv3)** and the overall nature of this automated environment, this project is distributed under GPLv3 to ensure compliance and promote open-source collaboration.

### Third-Party Software Credits
This project automates the installation of the following software. Please respect their respective licenses:

| Software | License |
| :--- | :--- |
| **[Mirakurun](https://github.com/Chinachu/Mirakurun)** | Apache License 2.0 |
| **[EDCB](https://github.com/xtne6f/EDCB)** | Civetweb / Lua License |
| **[EDCB_Material_WebUI](https://github.com/EMWUI/EDCB_Material_WebUI)** | Free |
| **[BonDriver_LinuxMirakc](https://github.com/matching/BonDriver_LinuxMirakc)** | MIT License |
| **[ISDBScanner](https://github.com/tsukumijima/ISDBScanner)** | MIT License |
| **[recisdb-rs](https://github.com/kazuki0824/recisdb-rs)** | GNU GPL v3.0 |
| **[libaribb25](https://github.com/tsukumijima/libaribb25)** | Apache License 2.0 |
| **[KonomiTV](https://github.com/tsukumijima/KonomiTV)** | MIT License |

### Disclaimer
* **Self-Responsibility:** This project is provided "as is" without any warranty. Use this software at your own risk.
* **Compliance:** Users are responsible for complying with local copyright laws and ARIB standards when using these tools for DTV reception and recording.
* **No Binary Distribution:** This repository provides build scripts that fetch sources from official repositories. We do not distribute pre-compiled binaries of copyrighted materials.
