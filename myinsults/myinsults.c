/*
 * myinsults.c - Random insult display with ANSI colors.
 *
 * Reads insults from ~/scripts/myinsults/insults.txt (one per line).
 * Compile: gcc -O2 -o myinsults myinsults.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define INSULT_FILE_REL "/scripts/myinsults/insults.txt"
#define MAX_INSULTS     1024
#define MAX_LINE_LEN    512

static const char *BORDER_COLORS[] = {
    "\e[38;5;240m",   /* Dark Grey     */
    "\e[38;5;244m",   /* Medium Grey   */
    "\e[38;5;67m",    /* Steel Blue    */
    "\e[38;5;66m",    /* Muted Teal    */
    "\e[38;5;97m",    /* Muted Purple  */
    "\e[38;5;101m",   /* Muted Olive   */
    "\e[38;5;109m",   /* Dusty Blue    */
    "\e[38;5;138m",   /* Muted Gold    */
};
#define N_BORDER_COLORS (int)(sizeof(BORDER_COLORS) / sizeof(BORDER_COLORS[0]))

static const char *INSULT_COLORS[] = {
    "\e[91m",         /* Bright Red    */
    "\e[93m",         /* Bright Yellow */
    "\e[95m",         /* Bright Magenta*/
    "\e[38;5;208m",   /* Orange        */
    "\e[38;5;201m",   /* Hot Pink      */
    "\e[38;5;82m",    /* Neon Green    */
    "\e[38;5;226m",   /* Gold          */
    "\e[38;5;51m",    /* Electric Blue */
    "\e[38;5;214m",   /* Coral         */
};
#define N_INSULT_COLORS (int)(sizeof(INSULT_COLORS) / sizeof(INSULT_COLORS[0]))

#define RESET "\e[0m"

/* Returns 1 if the string is blank/whitespace-only */
static int is_blank(const char *s)
{
    while (*s) {
        if (*s != ' ' && *s != '\t' && *s != '\r' && *s != '\n')
            return 0;
        s++;
    }
    return 1;
}

int main(void)
{
    const char *home = getenv("HOME");
    if (!home) {
        fprintf(stderr, "\e[31m$HOME not set\e[0m\n");
        return 1;
    }

    char path[512];
    snprintf(path, sizeof(path), "%s%s", home, INSULT_FILE_REL);

    FILE *f = fopen(path, "r");
    if (!f) {
        fprintf(stderr, "\e[31mNo insults.txt found at %s\e[0m\n", path);
        return 1;
    }

    /* Load insults, skipping blank lines */
    char *insults[MAX_INSULTS];
    int n = 0;
    char line[MAX_LINE_LEN];

    while (fgets(line, sizeof(line), f) && n < MAX_INSULTS) {
        /* Strip trailing newline */
        size_t len = strlen(line);
        while (len > 0 && (line[len-1] == '\n' || line[len-1] == '\r'))
            line[--len] = '\0';

        if (is_blank(line))
            continue;

        insults[n] = strdup(line);
        if (!insults[n]) {
            fprintf(stderr, "\e[31mOut of memory\e[0m\n");
            fclose(f);
            return 1;
        }
        n++;
    }
    fclose(f);

    if (n == 0) {
        fprintf(stderr, "\e[31mNo insults found in %s\e[0m\n", path);
        return 1;
    }

    srand((unsigned)time(NULL));

    const char *insult      = insults[rand() % n];
    const char *insult_col  = INSULT_COLORS[rand() % N_INSULT_COLORS];
    const char *border_col  = BORDER_COLORS[rand() % N_BORDER_COLORS];

    /* " <insult>" — leading space for padding, matching the bash original */
    int padded_len = (int)strlen(insult) + 2; /* 1 leading + 1 trailing space */

    /* Build border string */
    char *border = malloc(padded_len + 1);
    if (!border) {
        fprintf(stderr, "\e[31mOut of memory\e[0m\n");
        return 1;
    }
    memset(border, '=', padded_len);
    border[padded_len] = '\0';

    /* Print */
    printf("%s%s%s\n", border_col,  border,    RESET);
    printf("%s %s %s\n", insult_col, insult,   RESET);
    printf("%s%s%s\n", border_col,  border,    RESET);

    free(border);
    for (int i = 0; i < n; i++)
        free(insults[i]);

    return 0;
}
