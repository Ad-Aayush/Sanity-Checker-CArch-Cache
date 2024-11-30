%{
#include <stdio.h>
#include <string.h>
#include <math.h>
void yyerror(char *s);
%}

%%
0[xX][0-9a-fA-F]+ {
    // strip the 0s at beginning
    int i = 2;
    while(i < strlen(yytext) &&  yytext[i] == '0') {
        i++;
    }
    if(i == strlen(yytext) ){
        fprintf(stdout, "%s\n", "0x0");
    }
    else {
        int j = i;
        for(; j < strlen(yytext); j++) {
            if(yytext[j] >= 'A' && yytext[j] <= 'F') {
                yytext[j] += 32;
            }
        }
        fprintf(stdout, "%s%s\n", "0x", yytext + i);
    }
}

[Ss][Ee][Tt] {
    fprintf(stdout, "Set: ");
}

[Tt][Aa][Gg] {
    fprintf(stdout, "Tag: ");
}

[Cc][Ll][Ee][Aa][Nn] {
    fprintf(stdout, "Clean\n");
}

[Dd][Ii][Rr][Tt][Yy] {
    fprintf(stdout, "Dirty\n");
}

.|\n ;

%%

int yywrap() {
    return 1;
}

int main() {
    yylex();

    return 0;
}