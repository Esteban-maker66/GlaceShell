#!/usr/bin/env sh
# Install the user-level Glacé Shell dotfiles without embedding a home path.
set -eu

# SCRIPT_DIR is the setup/ directory; ROOT_DIR is the repository root.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
"$ROOT_DIR/scripts/maintenance/check-portability.sh"

if [ -z "${HOME:-}" ]; then
    printf '%s\n' 'HOME must be set.' >&2
    exit 1
fi

CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
DATA_HOME=${XDG_DATA_HOME:-"${HOME}/.local/share"}
INSTALL_ROOT="$CONFIG_HOME/GlaceShell"
SERVICE_DIR="$CONFIG_HOME/systemd/user"
SDDM_THEME_ROOT=${SDDM_THEME_ROOT:-"$DATA_HOME/sddm/themes"}
THEME_DIR="$SDDM_THEME_ROOT/GlaceShell"

copy_tree() {
    source_dir=$1
    destination_dir=$2

    if [ ! -d "$source_dir" ]; then
        return 0
    fi

    mkdir -p "$destination_dir"
    cp -R "$source_dir"/. "$destination_dir"/
}

printf '%s\n' "Installing Glacé Shell dotfiles in $INSTALL_ROOT"

mkdir -p "$INSTALL_ROOT" "$SERVICE_DIR"
copy_tree "$ROOT_DIR/config" "$INSTALL_ROOT/config"
copy_tree "$ROOT_DIR/scripts" "$INSTALL_ROOT/scripts"

cp "$ROOT_DIR/config/systemd/user/glace-ipc.service" "$SERVICE_DIR/glace-ipc.service"

# XKB reads this file directly from XDG_CONFIG_HOME. Preserve an existing
# user configuration instead of overwriting it.
if [ -f "$ROOT_DIR/config/kxkbrc" ] && [ ! -e "$CONFIG_HOME/kxkbrc" ]; then
    cp "$ROOT_DIR/config/kxkbrc" "$CONFIG_HOME/kxkbrc"
    : > "$INSTALL_ROOT/.kxkbrc-installed"
    printf '%s\n' 'XKB layout configuration installed.'
fi

# SDDM expects metadata.desktop and the referenced relative QML tree at the
# root of a theme directory. SDDM_THEME_ROOT can be overridden for a
# distribution with a different theme search policy.
mkdir -p "$THEME_DIR"
copy_tree "$ROOT_DIR/config" "$THEME_DIR/config"
cp "$ROOT_DIR/config/sddm/metadata.desktop" "$THEME_DIR/metadata.desktop"
cp "$ROOT_DIR/config/sddm/theme.conf" "$THEME_DIR/theme.conf"

if [ "${GLACE_SHELL_SKIP_SERVICE:-0}" = "1" ]; then
    printf '%s\n' 'Service activation skipped.'
elif command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload
    if systemctl --user enable --now glace-ipc.service; then
        printf '%s\n' 'Glacé Shell IPC service enabled.'
    else
        printf '%s\n' 'Could not start the IPC service; enable it from your user session later.' >&2
    fi
else
    printf '%s\n' 'systemd user services are unavailable; install the service manually if needed.' >&2
fi

printf '%s\n' "SDDM theme installed in $THEME_DIR"
printf '%s\n' "Set ThemeDir=$SDDM_THEME_ROOT and Current=GlaceShell in the SDDM configuration."
