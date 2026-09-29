# Glacé Shell - Architecture Overview

## Scope

Glacé Shell is a complete Linux desktop dotfiles project in development. The repository acts as a single source of truth for the user's visual configuration, SDDM greeter, desktop resources, integration scripts and user services.

## High-Level Architecture

The current implementation begins with a high-fidelity, modular SDDM theme written in Qt Quick/QML. A lightweight Python/Bash IPC bridge (`glace-ipc.service`) provides the system integration needed by the visual components.

QML components resolve fonts, wallpapers and icons relative to their own source files. The theme metadata also uses relative references, and the user service uses `%E` for `XDG_CONFIG_HOME` plus `%t` for the runtime directory instead of embedding a personal or installation path.

When an action needs system access, QML communicates with `config/quickshell/modules/glaceBridge.py` over HTTP on `127.0.0.1`. The bridge uses system tools such as `wpctl` and `nmcli` and can delegate keyboard changes to KDE, Hyprland, or X11.


## Main areas

- `config/sddm/`: SDDM entry point and metadata.
- `config/quickshell/components/`: reusable QML visual components.
- `config/quickshell/modules/`: local IPC and integration modules.
- `config/fonts/`, `config/Wallpapers/`, `config/shaders/` and `config/quickshell/assets/`: visual resources.
- `config/systemd/user/`: portable user-service definitions.
- `setup/`: install, update and uninstall entry points.
- `scripts/`: maintenance and portability checks.
- `test/`: isolated component previews.

The desktop-specific dotfiles will extend this same architecture as the project grows.

# Directory structure

The current implementation starts with the SDDM greeter, written in Qt Quick/QML. Visual components live in `config/quickshell/components` and are registered through `qmldir`. SDDM's entry point is `config/sddm/main.qml`.

```text
config/
├── sddm/                    # Entry point and theme metadata
├── quickshell/
│   ├── components/          # Reusable QML components
│   ├── modules/             # Local bridge and system utilities
│   └── assets/              # Icons
├── fonts/                   # Fonts
├── Wallpapers/              # Personal collection; only the default wallpaper is versioned
├── kxkbrc                   # Keyboard layout
├── shaders/                 # Resources for visual effects
└── systemd/user/            # User services
setup/                       # install.sh, update.sh, and uninstall.sh
scripts/
├── maintenance/             # Validation and cleanup utilities
└── ipc/                     # Compositor IPC bridge
test/testBench.qml           # Component test bench
docs/screenshots/            # Screenshots referenced by the README
LICENSE                      # Project license
```

## SDDM Architecture

SDDM loads `config/sddm/main.qml` as the greeter entry point. QtQuick/QML renders the interface and its components — such as `LoginPrompt`, `QuickDock`, and the status indicators — while `glace-ipc.service` exposes system information and actions through local IPC. Power actions are delegated to SDDM's `sddm` context; network state and Wi-Fi/Ethernet toggles use the bridge. The current service is a user service, so it is available in the desktop session; the pre-login SDDM greeter needs a bridge with a different lifecycle for the network controls. The following diagram summarizes this separation between the frontend and the backend.

```text
+-------------------------------------------------------+
|                 SDDM / QtQuick Frontend               |
|                                                       |
|   +---------------+   +---------------+  +--------+   |
|   |  LoginPrompt  |   |   QuickDock   |  |  Pill  |   |
|   +---------------+   +---------------+  +--------+   |
+---------------------------^---------------------------+
|                Local HTTP IPC (127.0.0.1)             |
+---------------------------v---------------------------+
|               glace-ipc.service (Backend)             |
|  - System Stats (Battery, Network, Weather)           |
|  - Battery endpoint (/battery -> sysfs)                |
+-------------------------------------------------------+
```
