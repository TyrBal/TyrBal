#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main() {
    FILE *file;
    char ch;
    char r_buffer[100];
    char w_buffer[250];
    int idx = 0;
    int process = 1; //processing state

    file = fopen("tokens.txt", "r");

    printf("Processing tokens:\n");

    while ((ch = fgetc(file)) != EOF) {
        if (!process) { 
            printf("w_buffer: %s\n", w_buffer);
            //add proccessing lol
            process = 1;
            continue;    //next character
        }

        if (process) {
            if (!isspace(ch)) {
                // Collect characters until whitespace
                r_buffer[idx++] = ch;
            } else {
                // Whitespace indicates the end of the token
                r_buffer[idx] = '\0'; // Null-terminate the string
                printf("Token: %s\n", r_buffer);

                // let's try appending the token to the w_buffer
                strcat(w_buffer, r_buffer);

                process = 0; 
                idx = 0; // Reset buffer index
            }
        }
    }

    // Handle the last token
    if (idx > 0) {
        r_buffer[idx] = '\0';
        printf("Token: %s\n", r_buffer);
    }

    fclose(file);
    return 0;
}
