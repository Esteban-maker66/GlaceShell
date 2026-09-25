#!/usr/bin/env sh
# Verify that dotfiles do not depend on a developer's home or checkout path.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

cd "$ROOT_DIR"

failed=0
home_root_marker="/$(printf '%s' home)/"
root_home_marker="/$(printf '%s' root)/"
users_root_marker="/$(printf '%s' Users)/"
opt_root_marker="/$(printf '%s' opt)/"
local_root_marker="/$(printf '%s' usr/local)/"
legacy_theme_marker="/$(printf '%s' usr/share/sddm/themes/GlaceShell)/"
file_url_prefix="file:$(printf '%s' ///)"

# Kernel-provided interfaces and localhost endpoints are valid application
# dependencies; they are not paths to a checkout or a particular user.
if grep -RInE --binary-files=without-match \
    --exclude-dir=.git \
    --exclude='check-portability.sh' \
    --exclude='*.pyc' \
    -e "${file_url_prefix}usr/" \
    -e "${file_url_prefix}home/" \
    -e "$home_root_marker" \
    -e "$root_home_marker" \
    -e "$users_root_marker" \
    -e "$opt_root_marker" \
    -e "$local_root_marker" \
    -e "$legacy_theme_marker" \
    -e '~/' \
    .; then
    failed=1
else
    grep_status=$?
    if [ "$grep_status" -gt 1 ]; then
        printf '%s\n' 'Portability check could not inspect every repository file.' >&2
        failed=1
    fi
fi

if find . -type f \( -name '*.pyc' -o -name '*.pyo' \) \
    -not -path './.git/*' -print -quit | grep -q .; then
    printf '%s\n' 'Generated Python bytecode must not be stored in the dotfiles.' >&2
    failed=1
fi

if [ "$failed" -ne 0 ]; then
    printf '%s\n' 'Portability check failed: remove hardcoded user or installation paths.' >&2
    exit 1
fi

printf '%s\n' 'Portability check passed: no personal or fixed installation paths found.'
