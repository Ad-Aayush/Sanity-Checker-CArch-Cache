%{
#include <stdio.h>
#include <string.h>
void yyerror(char *s);
%}

%%
0x[0-9a-fA-F]+ {
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
[Dd]-[Cc][Aa][Cc][Hh][Ee] { fprintf(stdout, "D-cache\n"); }


\-?[0-9]+ {fprintf(stdout, "%d\n", atoi(yytext));}
[Br][Rr][Ee][Aa][Kk][Pp][Oo][Ii][Nn][Tt] { fprintf(stdout, "Breakpoint\n"); }
[Ll][Ii][Nn][Ee] {fprintf(stdout, "line\n");}
\[ {fprintf(stdout, "[\n");}
\] {fprintf(stdout, "]\n");}
\( {fprintf(stdout, "(\n");}
\) {fprintf(stdout, ")\n");}

x([1-9]|[12][0-9]|3[01]|0) { fprintf(stdout, "%s\n", yytext); }


[Mm][Ee][Mm][Oo][Rr][Yy]             { fprintf(stdout, "memory\n"); }
[Ee][Xx][Ee][Cc][Uu][Tt][Ii][Oo][Nn] { fprintf(stdout, "Execution\n"); }
[Ss][Tt][Oo][Pp][Pp][Ee][Dd]         { fprintf(stdout, "stopped\n"); }
[Ss][Ee][Tt]                         { fprintf(stdout, "set\n"); }
[Ee][Mm][Pp][Tt][Yy]                 { fprintf(stdout, "empty\n"); }
[Aa][Tt]                             ;   // This rule will be ignored
[Tt][Hh][Ee]                         ;   // This rule will be ignored

[Dd][Ee][Ll]                        { fprintf(stdout, "del\n"); }
[Bb][Rr][Ee][Aa][Kk]               { fprintf(stdout, "break\n"); }




.|\n ;
%%

int yywrap() {
    return 1;
}
int main(){
    yylex();
    return 0;
}