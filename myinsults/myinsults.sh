#!/usr/bin/env bash
#
# Random insult display script using ANSI colors.
# Designed for dark terminal themes (Kitty recommended).
#
# Insults are the content, borders are framing.
# Border colors are muted to avoid competing with the insult.
# Insult colors are bright and saturated for maximum impact.
#
# Place insults in ~/scripts/myinsults/insults.txt (one per line).

INSULT_FILE="$HOME/scripts/myinsults/insults.txt"

# Muted border colors (256-color palette)
# These are intentionally low-saturation so they don't compete visually
BORDER_COLORS=(
    "\e[38;5;240m"   # Dark Grey
    "\e[38;5;244m"   # Medium Grey
    "\e[38;5;67m"    # Steel Blue
    "\e[38;5;66m"    # Muted Teal
    "\e[38;5;97m"    # Muted Purple
    "\e[38;5;101m"   # Muted Olive (misleading name, but nice tone)
    "\e[38;5;109m"   # Dusty Blue
    "\e[38;5;138m"   # Muted Gold
)

# Bright insult colors (this is the "star of the show")
INSULT_COLORS=(
    "\e[91m"         # Bright Red
    "\e[93m"         # Bright Yellow
    "\e[95m"         # Bright Magenta
    "\e[38;5;208m"   # Orange
    "\e[38;5;201m"   # Hot Pink
    "\e[38;5;82m"    # Neon Green
    "\e[38;5;226m"   # Gold
    "\e[38;5;51m"    # Electric Blue
    "\e[38;5;214m"   # Coral
)

RESET="\e[0m"

# Check if insult file exists
if [[ ! -f "$INSULT_FILE" ]]; then
    echo -e "\e[31mNo insults.txt found at $INSULT_FILE\e[0m"
    exit 1
fi

# Read insults (ignore blank lines)
mapfile -t INSULTS < <(grep -v '^[[:space:]]*$' "$INSULT_FILE")

# Check if we actually got insults
if [[ ${#INSULTS[@]} -eq 0 ]]; then
    echo -e "\e[31mNo insults found in $INSULT_FILE\e[0m"
    exit 1
fi

# Pick random insult
INSULT="${INSULTS[RANDOM % ${#INSULTS[@]}]}"
INSULT=" $INSULT"  # leading space for nicer padding

# Pick random colors from separate pools
INSULT_COLOR="${INSULT_COLORS[RANDOM % ${#INSULT_COLORS[@]}]}"
BORDER_COLOR="${BORDER_COLORS[RANDOM % ${#BORDER_COLORS[@]}]}"

# Build border line based on insult length
INSULT_LEN=$((${#INSULT} + 1))
BORDER_LINE=$(printf '%*s' "$INSULT_LEN" '' | tr ' ' '=')

# Output framed insult
echo -e "${BORDER_COLOR}${BORDER_LINE}${RESET}"
echo -e "${INSULT_COLOR}${INSULT}${RESET}"
echo -e "${BORDER_COLOR}${BORDER_LINE}${RESET}"
