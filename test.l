%{
#include <stdio.h>
#include <string.h>
#include <math.h>
void yyerror(char *s);
%}

%%
[0-9]+.[0-9]+ {
    double num = atof(yytext);
    

    fprintf(stdout, "%0.2lf\n", num);
}

[Hh][Ii][Tt][ |\-][Rr][Aa][Tt][Ee] { fprintf(stdout, "Hit Rate: "); }
[Dd]-[Cc][Aa][Cc][Hh][Ee] { fprintf(stdout, "D-cache "); }
[Hh][Ii][Tt][Ss]? { fprintf(stdout, "Hit: "); }
[Mm][Ii][Ss][Ss] { fprintf(stdout, "Miss: "); }
[Aa][Cc][Cc][Ee][Ss][Ss][Ee][Ss] { fprintf(stdout, "Accesses: "); }
[Aa][Cc][Cc][Ee][Ss] { fprintf(stdout, "Access: "); }



\-?[0-9]+ {fprintf(stdout, "%d\n", atoi(yytext));}
[Br][Rr][Ee][Aa][Kk][Pp][Oo][Ii][Nn][Tt] { fprintf(stdout, "Breakpoint\n"); }
[Ll][Ii][Nn][Ee] {fprintf(stdout, "line\n");}
\[ {fprintf(stdout, "[\n");}
\] {fprintf(stdout, "]\n");}
\( {fprintf(stdout, "(\n");}
\) {fprintf(stdout, ")\n");}

x([1-9]|[12][0-9]|3[01]|0) ; 

executed.* ;

([Ee][Xx][Ee][Cc][Uu][Tt][Ee][Dd])|([Ee][Xx][Ee][Cc][Uu][Tt][Ee])|([Ee][Xx][Ee][Cc][Uu][Tt][Ii][Nn][Gg]).* ;

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