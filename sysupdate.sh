#!/usr/bin/env bash

# ============================================================================
#  System Update Menu (Arch Linux)
# ============================================================================
#  A small interactive CLI tool for running common system update commands.
#
#  Features:
#   - Multi-select input (e.g. 1 3, 2,1, etc.)
#   - Run all option (A)
#   - Clean exit option (Q)
#   - Fixed execution order (1 → 2 → 3 regardless of input order)
#   - Simple colour-coded output for readability
#
#  Intended use:
#   Run manually when you want a quick update interface instead of typing
#   commands individually.
#
# ============================================================================


# =========================
#  Colors (ANSI escape codes)
# =========================
HEADER=$'\e[96m'    # Cyan (menu header)
KEY=$'\e[38;5;45m'  # Aqua (menu keys: numbers, A, Q)
CMD=$'\e[97m'       # Bright white (command text)
DESC=$'\e[38;5;82m' # Neon green (descriptions)
SUCCESS=$'\e[92m'   # Green (success state)
ERROR=$'\e[91m'     # Red (errors / invalid input)
RUNNING=$'\e[93m'   # Yellow (currently executing command)
RESET=$'\e[0m'      # Reset terminal formatting


# =========================
#  Menu Definition
# =========================
# Format: "command|description"
# Keep everything in one array for easier maintenance
menu=(
    "sudo pacman -Syu|Full system update (official repos)"
    "paru -Syu|AUR + repo update"
    "flatpak update|Flatpak applications update"
)


# =========================
#  Split menu into usable arrays
# =========================
# We separate command + description for easier formatted printing later
commands=()
descriptions=()

for item in "${menu[@]}"; do
    IFS='|' read -r cmd desc <<< "$item"
    commands+=("$cmd")
    descriptions+=("$desc")
done


# =========================
#  Display Menu
# =========================
echo -e "${HEADER}=============================="
echo -e "  System Update Menu"
echo -e "==============================${RESET}"

# Print numbered options
for i in "${!commands[@]}"; do
    printf " %s%d.%s %s%s%s %s%s%s\n" \
        "${KEY}" "$((i+1))" "${RESET}" \
        "${CMD}" "${commands[$i]}" "${RESET}" \
        "${DESC}" "${descriptions[$i]}" "${RESET}"
done

# Extra actions (kept in same visual group for simplicity)
printf " %sA.%s %sRun All updates%s\n" "${KEY}" "${RESET}" "${CMD}" "${RESET}"
printf " %sQ.%s %sQuit%s\n" "${KEY}" "${RESET}" "${CMD}" "${RESET}"
echo "------------------------------"


# =========================
#  User Input
# =========================
echo -ne "${KEY} Select option(s): ${RESET}"
read -r input
echo

# Normalise input:
# - lowercase everything
# - allow comma-separated input (1,2 → 1 2)
input="${input,,}"
input="${input//,/ }"

# Immediate exit shortcuts
[[ "$input" =~ ^(q|quit|exit)$ ]] && echo "Exiting." && exit 0

# Stores indices of selected commands
to_run=()


# =========================
#  Selection Logic
# =========================
if [[ "$input" =~ ^(a|all)$ ]]; then
    # Select everything
    for i in "${!commands[@]}"; do
        to_run+=("$i")
    done
else
    # Parse numeric selections
    for token in $input; do
        if [[ "$token" =~ ^[0-9]+$ ]]; then
            idx=$((token - 1))

            # Validate index range
            if (( idx >= 0 && idx < ${#commands[@]} )); then
                # Prevent duplicates
                [[ " ${to_run[*]} " =~ " $idx " ]] || to_run+=("$idx")
            else
                echo -e "${ERROR}Invalid option: $token${RESET}"
            fi
        else
            echo -e "${ERROR}Invalid input: $token${RESET}"
        fi
    done
fi

# Nothing selected → exit cleanly
[[ ${#to_run[@]} -eq 0 ]] && echo "Nothing selected." && exit 0


# =========================
#  Execution (fixed order: 1 → 2 → 3)
# =========================
# Always runs in menu order, NOT user input order
for idx in "${!commands[@]}"; do
    if [[ " ${to_run[*]} " =~ " $idx " ]]; then
        echo -e "${RUNNING}>>> Running:${RESET} ${commands[$idx]}"

        # Execute command safely in a subshell
        bash -c "${commands[$idx]}"
        status=$?

        # Report result
        if [[ $status -eq 0 ]]; then
            echo -e "${SUCCESS}>>> Success${RESET}"
        else
            echo -e "${ERROR}>>> Failed (exit code: $status)${RESET}"
        fi

#        echo
    fi
done

exit 0
