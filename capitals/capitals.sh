#!/usr/bin/env bash

###############################################################################
#                                                                             #
# Script Name : capitals.sh                                                   #
# Description : Country and Capital City quiz game.                           #
#                                                                             #
#               The script randomly asks either:                              #
#                                                                             #
#               - What is the capital city of a country?                      #
#               - Which country has a given capital city?                     #
#                                                                             #
#               Five multiple-choice answers (A-E) are presented, with one    #
#               correct answer and four randomly selected incorrect answers.  #
#                                                                             #
#               The quiz continues until the user chooses to quit.            #
#                                                                             #
# Requirements:                                                               #
#               - Bash                                                        #
#               - capitals.txt database                                       #
#                                                                             #
# Author      : Peter                                                         #
# Version     : 1.1                                                           #
#                                                                             #
###############################################################################

########################################
# Database Configuration
########################################

DATABASE="$HOME/scripts/capitals/capitals.txt"

########################################
# Color Configuration
########################################

CLR_RESET="\e[0m"             # Reset to terminal default

CLR_TITLE="\e[1;97m"          # Bright White
CLR_QUESTION="\e[1;96m"       # Bright Cyan
CLR_OPTION="\e[1;93m"         # Bright Yellow
CLR_PROMPT="\e[1;97m"         # Bright White

CLR_SUCCESS="\e[1;92m"        # Bright Green
CLR_ERROR="\e[38;5;203m"      # Light Red

CLR_INFO="\e[1;96m"           # Bright Cyan
CLR_SCORE="\e[1;97m"          # Bright White

########################################
# Global Variables
########################################

score_correct=0
score_incorrect=0

########################################
# Function: Press Enter
########################################

pause_screen()
{
    echo
    read -rp "Press Enter to continue..."
}

########################################
# Function: Display Header
########################################

display_header()
{
    clear

    echo -e "${CLR_TITLE}"
    echo "=============================================================="
    echo "                 COUNTRY CAPITALS QUIZ"
    echo "=============================================================="
    echo -e "${CLR_RESET}"

    echo -e "${CLR_SCORE}Correct : ${score_correct}${CLR_RESET}"
    echo -e "${CLR_SCORE}Incorrect : ${score_incorrect}${CLR_RESET}"
    echo
}

########################################
# Function: Verify Database
########################################

check_database()
{
    local total_entries

    if [[ ! -f "$DATABASE" ]]; then
        echo -e "${CLR_ERROR}ERROR:${CLR_RESET} Database not found."
        echo "$DATABASE"
        exit 1
    fi

    if [[ ! -s "$DATABASE" ]]; then
        echo -e "${CLR_ERROR}ERROR:${CLR_RESET} Database is empty."
        exit 1
    fi

    total_entries=$(grep -c '' "$DATABASE")

    if [[ "$total_entries" -lt 5 ]]; then
        echo -e "${CLR_ERROR}ERROR:${CLR_RESET} Database must contain at least 5 entries."
        exit 1
    fi
}

########################################
# Function: Get Random Line Number
########################################

get_random_line()
{
    local total_lines

    total_lines=$(grep -c '' "$DATABASE")

    shuf -i 1-"$total_lines" -n 1
}

########################################
# Function: Get Country/Capital Pair
########################################

get_record()
{
    local line_number="$1"

    sed -n "${line_number}p" "$DATABASE"
}

########################################
# Function: Shuffle Array
########################################

shuffle_array()
{
    printf '%s\n' "$@" | shuf
}

########################################
# Function: Generate Question
########################################

generate_question()
{
    local record
    local country
    local capital

    local question_type

    local correct_answer
    local correct_letter

    local distractors
    local answer

    local letter
    local value

    local letters=(A B C D E)
    local answers

    record=$(get_record "$(get_random_line)")

    country="${record%%|*}"
    capital="${record##*|}"

    question_type=$(( RANDOM % 2 ))

    if [[ "$question_type" -eq 0 ]]; then

        ################################
        # Country -> Capital
        ################################

        correct_answer="$capital"

        mapfile -t distractors < <(
            cut -d'|' -f2 "$DATABASE" |
            grep -Fxv "$capital" |
            shuf -n 4
        )

        echo -e "${CLR_QUESTION}"
        echo "What is the capital city of ${country}?"
        echo -e "${CLR_RESET}"

    else

        ################################
        # Capital -> Country
        ################################

        correct_answer="$country"

        mapfile -t distractors < <(
            cut -d'|' -f1 "$DATABASE" |
            grep -Fxv "$country" |
            shuf -n 4
        )

        echo -e "${CLR_QUESTION}"
        echo "${capital} is the capital city of which country?"
        echo -e "${CLR_RESET}"

    fi

    mapfile -t answers < <(
        shuffle_array \
            "$correct_answer" \
            "${distractors[0]}" \
            "${distractors[1]}" \
            "${distractors[2]}" \
            "${distractors[3]}"
    )

    for i in "${!answers[@]}"
    do
        if [[ "${answers[i]}" == "$correct_answer" ]]; then
            correct_letter="${letters[i]}"
            break
        fi
    done
    for i in "${!answers[@]}"
    do
        echo -e "${CLR_OPTION}${letters[i]})${CLR_RESET} ${answers[i]}"
    done

    echo
    echo -e "${CLR_PROMPT}Choose A-E or Q to quit:${CLR_RESET}"

    while true
    do
        read -r answer

        answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

        case "$answer" in
            A|B|C|D|E|Q)
                break
                ;;
            *)
                echo -e "${CLR_ERROR}Please enter A, B, C, D, E or Q.${CLR_RESET}"
                ;;
        esac
    done

    if [[ "$answer" == "Q" ]]; then
        echo
        echo -e "${CLR_INFO}Final Score${CLR_RESET}"
        echo "Correct   : $score_correct"
        echo "Incorrect : $score_incorrect"
        echo
        exit 0
    fi

    echo

    if [[ "$answer" == "$correct_letter" ]]; then

        ((++score_correct))

        echo -e "${CLR_SUCCESS}Yes, you are correct!${CLR_RESET}"
        echo

    else

        ((++score_incorrect))

        echo -e "${CLR_ERROR}Sorry, you are NOT correct.${CLR_RESET}"
        echo
        echo "The correct answer was:"
        echo "${correct_letter}) ${correct_answer}"
        echo

    fi

    if [[ "$question_type" -eq 0 ]]; then
        echo -e "${CLR_INFO}The capital city of ${country} is ${capital}.${CLR_RESET}"
    else
        echo -e "${CLR_INFO}The capital city of ${country} is ${capital}.${CLR_RESET}"
    fi

    pause_screen
}

########################################
# Main Program
########################################

check_database

while true
do
    display_header
    generate_question
done
