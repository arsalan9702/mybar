# mybar — a custom Quickshell top bar for KDE Plasma

A from-scratch replacement for Plasma's default panel, built with
[Quickshell](https://quickshell.org) on Fedora. It runs standalone, alongside
(or instead of) Plasma's own panel, and talks directly to system services
(PipeWire, BlueZ, NetworkManager, UPower/PowerProfiles) via Quickshell's
QML bindings rather than shelling out to CLI tools wherever a proper API exists.

---

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Directory structure](#directory-structure)
- [Architecture](#architecture)
- [Installation](#installation)
- [Building Quickshell from source](#building-quickshell-from-source)
- [Running](#running)
- [Autostart (systemd)](#autostart-systemd)
- [Auto-rebuild on Qt updates](#auto-rebuild-on-qt-updates)
- [Icons](#icons)
- [Known limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)

---

## Features

**Left side**
- **Volume** — shows current output device + level, live-reactive to PipeWire.
  Click to open a popup with separate output/input sliders, mute toggles, and
  a shortcut into KDE's audio settings. Scroll on the bar icon to nudge volume
  without opening the popup.
- **Bluetooth** — one icon per currently connected device (e.g. mouse +
  headset shows three icons: base Bluetooth state + a mouse icon + a headset
  icon), so you can see everything connected at a glance without opening
  anything. Click opens a popup listing all known devices with connect/
  disconnect and battery level where reported.
- **WiFi** — signal-strength-aware icon, popup lists nearby networks sorted
  strongest-first (scrollable past 6), toggle WiFi on/off, connect to known
  networks with one click.
- **Battery** — vertical battery icon that changes shape and color by charge
  level and charging state. Popup shows percentage, time remaining/until
  full, and a three-way segmented control for power profiles (Efficient /
  Balanced / Power).

**Center**
- **Clock** — `ddmmyy  HH:mm`, 24-hour, updates every minute. Click opens a
  navigable month calendar with today highlighted.

**Right**
- **Power button** — opens KDE's native logout/restart/shutdown screen.

All popups follow the same visual language (dark rounded card, accent-colored
highlights, hairline dividers) and only one can be open at a time — opening
a new one closes whatever was already open.

---

## Requirements

- Fedora with KDE Plasma 6, Wayland session (KWin)
- PipeWire + WirePlumber, BlueZ, NetworkManager, UPower, `tuned-ppd` or
  `power-profiles-daemon` (whichever your system uses for power profiles)
- Qt6 (`qt6-qtbase`, `qt6-qtdeclarative`, `qt6-qtsvg`, `qt6-qt5compat`)
- `cliphist` + `wl-clipboard` (for the clipboard feature, if/when implemented)
- A Quickshell build linked against your **current** installed Qt6 — see
  [Building Quickshell from source](#building-quickshell-from-source) for why
  this matters on Fedora specifically.

---

## Directory structure

```
~/.config/quickshell/mybar/
├── shell.qml                  # entry point — instantiates Bar per screen
├── Bar.qml                    # PanelWindow: left/center/right RowLayouts
├── Theme.qml                  # singleton: colors, spacing, fonts, timings
├── qmldir                     # root module def (declares Theme, Bar)
├── services/                  # singletons wrapping system state
│   ├── PipewireService.qml
│   ├── BluetoothService.qml
│   ├── NetworkService.qml
│   ├── BatteryService.qml
│   └── PopupManager.qml       # ensures only one popup is open at a time
├── modules/
│   ├── PhosphorIcon.qml       # shared themed-icon component (see Icons)
│   ├── left/
│   │   ├── VolumeButton.qml
│   │   ├── BluetoothButton.qml
│   │   ├── WifiButton.qml
│   │   └── BatteryButton.qml
│   ├── center/
│   │   └── ClockWidget.qml
│   └── right/
│       └── PowerButton.qml
├── popups/
│   ├── VolumePopup.qml
│   ├── DeviceRow.qml           # shared row used by Volume's output/input lists
│   ├── StyledSlider.qml        # themed QtQuick.Controls Slider
│   ├── WifiPopup.qml
│   ├── BluetoothPopup.qml
│   ├── BatteryPopup.qml
│   └── CalendarPopup.qml
└── assets/
    └── icons/                  # local Phosphor Icons SVGs (see Icons)
```

Every directory with QML files meant to be imported has a `qmldir` listing
them — this is required by the QML module system, not optional bookkeeping.

---

## Architecture

**Services vs. modules vs. popups.** Services are `pragma Singleton` QML
files that wrap a system API (PipeWire, BlueZ, NetworkManager, UPower) and
expose only clean, UI-ready properties/functions — no widget ever touches
D-Bus or a raw system object directly. Modules are the small bar-icon
widgets. Popups are the expandable panels that open on click. This split
means swapping a backend, or restyling a widget, only ever touches one file.

**The `qs.` import scheme.** Cross-directory imports use Quickshell's
`import qs`, `import qs.services`, `import qs.modules`, etc. — this resolves
relative to the shell's root directory (wherever `shell.qml` lives) and is
what Quickshell's own LSP understands, unlike relative `"../../"` path
imports, which broke in a few places during development once directories
picked up `qmldir` module declarations.

**Fixed-size popup windows.** Popups whose content changes size while open
(WiFi's network list collapsing/expanding, Battery — though Battery's is
actually static) set the `PopupWindow`'s `implicitWidth`/`implicitHeight` to
a **fixed** worst-case size, and only animate the *inner* `Rectangle`.
Animating the actual window size directly caused visible jitter, because
every frame was triggering a real Wayland compositor resize instead of a
cheap GPU repaint.

**Icon tinting.** SVG icons are colored via `layer.effect: MultiEffect`
(Qt6's `QtQuick.Effects` module) rather than relying on the SVG's own fill,
since Phosphor's SVGs use `fill="currentColor"`, which Qt's SVG renderer
doesn't resolve dynamically the way a browser would. See [Icons](#icons).

**One popup at a time.** `services/PopupManager.qml` is a tiny singleton
that every bar button's click handler goes through instead of toggling its
own popup's `visible` directly — it closes whatever else is open first. This
exists because two simultaneously-open `PopupWindow`s violate the Wayland
`xdg-popup` protocol's single-grab rule and produced real compositor
warnings before this was added.

---

## Installation

```bash
mkdir -p ~/.config/quickshell/mybar/{services,modules/{left,center,right},popups,assets/icons}
```

Install runtime dependencies (most ship with a stock KDE Plasma + PipeWire
Fedora install already):

```bash
sudo dnf install pipewire pipewire-pulseaudio wireplumber bluez \
    NetworkManager upower wl-clipboard qt6-qtdeclarative qt6-qtsvg \
    qt6-qtimageformats qt6-qt5compat
```

> **Power profiles:** Fedora 44+ ships `tuned-ppd` by default, which
> provides the same `net.hadess.PowerProfiles` D-Bus interface as
> `power-profiles-daemon` — install only one, they conflict on purpose.
> Everything in this project talks to that D-Bus interface, so it works
> with either backend.

`cliphist` isn't in Fedora's core repos:
```bash
sudo dnf copr enable solopasha/hyprland
sudo dnf install cliphist
```

---

## Building Quickshell from source

**Fedora's COPR build of Quickshell can lag behind Fedora's own Qt6
point-release updates**, causing a hard ABI crash
(`undefined symbol: _ZN23QUntypedPropertyBinding...`) at launch. Building
from source against your *currently installed* Qt6 avoids this entirely,
and is what this project assumes.

```bash
sudo dnf install cmake ninja-build gcc-c++ git \
    qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtwayland-devel \
    qt6-qtsvg-devel qt6-qtshadertools-devel qt6-qt5compat-devel \
    qt6-qtbase-private-devel qt6-qtdeclarative-private-devel \
    pipewire-devel wayland-protocols-devel cli11-devel spdlog-devel jemalloc-devel

git clone --recursive https://github.com/quickshell-mirror/quickshell.git ~/src/quickshell
cd ~/src/quickshell
cmake -GNinja -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

The `-private-devel` packages are required — Quickshell links against Qt's
private APIs (`Qt6CorePrivate`, `Qt6QuickPrivate`), which are not included
in the standard `-devel` packages.

See [Auto-rebuild on Qt updates](#auto-rebuild-on-qt-updates) for keeping
this in sync automatically after future Qt updates.

---

## Running

```bash
quickshell -c mybar
```

Remove Plasma's own panel first (right-click it → Edit Mode → panel handle
→ Remove Panel) so the two don't overlap.

---

## Autostart (systemd)

A user-level systemd service is more robust than a plain KDE autostart
entry — it auto-restarts on crash and integrates with proper session
lifecycle ordering.

```ini
# ~/.config/systemd/user/quickshell.service
[Unit]
Description=Quickshell (mybar)
PartOf=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/quickshell -c mybar
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now quickshell.service
```

---

## Auto-rebuild on Qt updates

Because Quickshell is a manual out-of-tree build, nothing rebuilds it
automatically the way Fedora rebuilds its own Qt-linked packages (e.g.
`plasmalogin`) in lockstep with a Qt update. This project uses DNF's
`post-transaction-actions` plugin to trigger a rebuild automatically
whenever `qt6-qtbase` or `qt6-qtdeclarative` change.

```bash
sudo dnf install python3-dnf-plugin-post-transaction-actions
```

`/usr/local/bin/rebuild-quickshell.sh` — rebuilds, reinstalls, restarts the
systemd service, and sends a desktop notification at each stage (including
on failure, with the specific step that failed):

```bash
#!/bin/bash
set -e
LOG=/var/log/quickshell-rebuild.log
USER_ID=$(id -u arsalan)
export XDG_RUNTIME_DIR="/run/user/$USER_ID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

notify() {
    runuser -l arsalan -c "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS notify-send '$1' '$2' -i preferences-desktop-theme" >> "$LOG" 2>&1 || true
}

echo "=== Quickshell rebuild triggered $(date) ===" >> "$LOG"
notify "Quickshell" "Qt updated — rebuilding quickshell in the background..."

cd /home/arsalan/src/quickshell
if ! git pull >> "$LOG" 2>&1; then
    notify "Quickshell rebuild failed" "git pull failed — check /var/log/quickshell-rebuild.log"
    exit 1
fi

rm -rf build
if ! cmake -GNinja -B build -DCMAKE_BUILD_TYPE=Release >> "$LOG" 2>&1; then
    notify "Quickshell rebuild failed" "cmake configure failed — check /var/log/quickshell-rebuild.log"
    exit 1
fi

if ! cmake --build build >> "$LOG" 2>&1; then
    notify "Quickshell rebuild failed" "build failed — check /var/log/quickshell-rebuild.log"
    exit 1
fi

if ! cmake --install build >> "$LOG" 2>&1; then
    notify "Quickshell rebuild failed" "install failed — check /var/log/quickshell-rebuild.log"
    exit 1
fi

echo "=== Rebuild complete, restarting service $(date) ===" >> "$LOG"
runuser -l arsalan -c 'systemctl --user restart quickshell.service' >> "$LOG" 2>&1

notify "Quickshell rebuilt" "Bar rebuilt and restarted successfully against the new Qt."
```

```bash
sudo chmod +x /usr/local/bin/rebuild-quickshell.sh
```

`/etc/dnf/plugins/post-transaction-actions.d/quickshell-rebuild.action`:
```
qt6-qtbase*:in:/usr/local/bin/rebuild-quickshell.sh
qt6-qtdeclarative*:in:/usr/local/bin/rebuild-quickshell.sh
```

**Limitation:** this rebuilds *after* the DNF transaction completes, so
there's a short window (however long the rebuild takes) where the running
bar is still linked against the old Qt. This is a strictly better guarantee
than "stays broken until you notice," but not as strong as Fedora's own
lockstep-rebuilt packages, which never have this gap.

---

## Icons

Icons come from [Phosphor Icons](https://phosphoricons.com) (MIT licensed),
stored locally as raw SVGs under `assets/icons/` rather than referenced from
a system icon theme — this project doesn't use freedesktop icon-theme
lookups (`IconImage`) except conceptually considered and rejected in favor
of a single coherent icon family.

**Two things every icon file needs before use:**

1. **Recolor the fill.** Phosphor's SVGs ship with `fill="currentColor"`,
   which only resolves in a browser/CSS context — Qt's SVG renderer doesn't
   understand it and renders black. Every icon file has been patched:
   ```bash
   sed -i 's/currentColor/#000000/' assets/icons/some-icon.svg
   ```
   The exact replacement color doesn't matter much — it's just a base for
   `MultiEffect` to recolor from at render time (see below) — but it must be
   a real resolvable color, not `currentColor`.

2. **Reference via `PhosphorIcon`, not a raw `Image`.** `modules/PhosphorIcon.qml`
   wraps the icon in a `layer.effect: MultiEffect { colorization: 1.0;
   colorizationColor: ... }`, which is what actually applies your theme's
   color at render time:
   ```qml
   PhosphorIcon {
       icon: "speaker-high.svg"     // filename only, resolved relative to assets/icons/
       color: Theme.foreground
   }
   ```

Filenames are Phosphor's own naming convention with **no weight suffix**
for the `regular` weight (e.g. `speaker-high.svg`, not
`speaker-high-regular.svg`) — other weights (`bold`, `fill`, etc.) do carry
a suffix if you ever mix weights in.

---

## Known limitations

- **WiFi password entry:** Quickshell doesn't ship a NetworkManager
  authentication agent, so connecting to a *new*, unsaved network from the
  popup will silently fail — there's nowhere for it to prompt you for a
  password. Already-known networks (ones connected to previously via KDE's
  own tools) connect fine. First-time connections still need
  `kcmshell6 kcm_networkmanagement` (the popup's settings gear).
- **Bluetooth device-type detection** relies on BlueZ's reported `icon`
  string (e.g. `audio-headset`, `input-mouse`) via substring matching. Some
  devices/firmware may report atypical icon strings that don't match either
  bucket, in which case they fall back to a generic Bluetooth icon rather
  than mouse/headset.
- **Calendar** is a pure display/navigation widget — no event integration.
- **Clipboard, Settings-icon-as-launcher,** and a couple of other originally
  planned features are stubbed in the architecture (see `PipewireService`'s
  design notes) but not yet built.

---

## Troubleshooting

**Bar won't launch / `symbol lookup error`:** Quickshell is linked against
a different Qt6 than what's installed. Rebuild from source (see above), or
check whether the auto-rebuild hook already fired: `cat /var/log/quickshell-rebuild.log`.

**A QML type is "not a type" / "module X is not installed":** almost always
a missing `qmldir` entry for that file's directory, or a leftover relative
(`"../../"`) import that should be `import qs...` instead.

**Icon renders solid black:** the SVG still has `fill="currentColor"` —
run the `sed` fix from [Icons](#icons).

**Popup animation is jittery/stutters:** the `PopupWindow`'s
`implicitWidth`/`implicitHeight` is bound directly to animated content
instead of being fixed — see the fixed-size-window note in
[Architecture](#architecture).

**Two popups open at once / Wayland `xdg-popup` warnings in terminal:**
a button's click handler is toggling its popup's `visible` directly instead
of going through `Services.PopupManager.requestOpen(...)`.