#!/usr/bin/env bash

# list-pacman-updates.sh
#
# Lists available Arch Linux package updates with descriptions.
# Uses checkupdates from pacman-contrib.
#
# This script does not install, upgrade, or modify any packages.
#
# Author: Terminally Blunt
# URL:    https://github.com/terminallyblunt

# =========================
# Colors
# =========================
HEADER=$'\e[96m'    # Cyan
PACKAGE=$'\e[97m'   # Bright white
DESC=$'\e[38;5;82m' # Green
STATUS=$'\e[93m'   # Bright yellow
RESET=$'\e[0m'     # Reset

# =========================
# Check dependencies
# =========================
if ! command -v checkupdates >/dev/null 2>&1; then
    printf '%sError: checkupdates is not installed.%s\n' "$STATUS" "$RESET" >&2
    printf 'Install it with: sudo pacman -S pacman-contrib\n' >&2
    exit 1
fi

# =========================
# Get available updates
# =========================
printf '%sChecking for available updates...%s\n\n' "$STATUS" "$RESET"

updates_raw=$(checkupdates)
rc=$?

case $rc in
    0)
        ;;
    2)
        printf '%s✓ No updates available. Your system is up to date!%s\n' \
            "$STATUS" "$RESET"
        exit 0
        ;;
    *)
        printf '%sError: checkupdates failed (exit code %d).%s\n' \
            "$STATUS" "$rc" "$RESET" >&2
        exit 1
        ;;
esac

mapfile -t updates < <(printf '%s\n' "$updates_raw" | awk '{print $1}')

# =========================
# Determine package column width
# =========================
package_width=7  # Length of "PACKAGE"

for pkg in "${updates[@]}"; do
    if (( ${#pkg} > package_width )); then
        package_width=${#pkg}
    fi
done

# Add a little breathing room between columns.
((package_width += 2))

# =========================
# Print header
# =========================
printf '%s%-*s%s %sDESCRIPTION%s\n' \
    "$HEADER" "$package_width" "PACKAGE" "$RESET" "$HEADER" "$RESET"

printf '%s%-*s%s %s%s%s\n' \
    "$HEADER" "$package_width" "-------" "$RESET" "$HEADER" \
    "-----------" "$RESET"

# =========================
# Print packages
# =========================
for pkg in "${updates[@]}"; do
    desc=$(pacman -Qi "$pkg" | sed -n 's/^Description *: //p')

    printf '%s%-*s%s %s%s%s\n' \
        "$PACKAGE" "$package_width" "$pkg" "$RESET" \
        "$DESC" "$desc" "$RESET"
done

# =========================
# Summary
# =========================
echo
printf '%sTotal packages to update: %s%d%s\n' \
    "$STATUS" "$PACKAGE" "${#updates[@]}" "$RESET"
