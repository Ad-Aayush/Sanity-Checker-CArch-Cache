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


\-?[0-9]+ {fprintf(stdout, "%d\n", atoi(yytext));}

[Br][Rr][Ee][Aa][Kk][Pp][Oo][Ii][Nn][Tt] { fprintf(stdout, "Breakpoint\n"); }

[Ll][Ii][Nn][Ee] {fprintf(stdout, "line\n");}

\[ {fprintf(stdout, "[\n");}
\] {fprintf(stdout, "]\n");}
\( {fprintf(stdout, "(\n");}
\) {fprintf(stdout, ")\n");}
a([0-7])    { int reg_num = 10 + atoi(yytext+1); fprintf(stdout, "x%d\n", reg_num); }
s([0-9]|1[01]) { int reg_num = 8 + atoi(yytext+1); fprintf(stdout, "x%d\n", reg_num); }
t([0-2])    { int reg_num = 5 + atoi(yytext+1); fprintf(stdout, "x%d\n", reg_num); }
t([3-6])    { int reg_num = 28 + atoi(yytext+1); fprintf(stdout, "x%d\n", reg_num); }
f([0-9]|[12][0-9]|3[01])  { fprintf(stdout, "f%s\n", yytext+1); }
ra          { fprintf(stdout, "x1\n"); }
sp          { fprintf(stdout, "x2\n"); }
gp          { fprintf(stdout, "x3\n"); }
tp          { fprintf(stdout, "x4\n"); }
zero        { fprintf(stdout, "x0\n"); }

x([1-9]|[12][0-9]|3[01]|0) { fprintf(stdout, "%s\n", yytext); }
= { fprintf(stdout, "=\n"); }


[Mm][Ee][Mm][Oo][Rr][Yy]             { fprintf(stdout, "memory\n"); }
([Ee][Xx][Ee][Cc][Uu][Tt][Ee][Dd])|([Ee][Xx][Ee][Cc][Uu][Tt][Ee])|([Ee][Xx][Ee][Cc][Uu][Tt][Ii][Nn][Gg]) {
     fprintf(stdout, "Executed\n"); 
     }
[Ee][Xx][Ee][Cc][Uu][Tt][Ii][Oo][Nn] { fprintf(stdout, "Execution\n"); }
[Ss][Tt][Oo][Pp][Pp][Ee][Dd]         { fprintf(stdout, "stopped\n"); }
[Ss][Ee][Tt]                         { fprintf(stdout, "set\n"); }
[Pp][Cc]                         { fprintf(stdout, "PC\n"); }
[Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Ss]  { fprintf(stdout, "Registers\n"); }
[Nn][Oo][Tt][Hh][Ii][Nn][Gg]         { fprintf(stdout, "Nothing\n"); }
[Ss][Tt][Ee][Pp]                     { fprintf(stdout, "step\n"); }
([Ee][Xx][Ii][Tt][Ee][Dd])|([Ee][Xx][Ii][Tt]) { 
    fprintf(stdout, "Exited\n"); 
    }
[Ss][Ii][Mm][Uu][Ll][Aa][Tt][Oo][Rr] { fprintf(stdout, "simulator\n"); }
[Ee][Mm][Pp][Tt][Yy]                 { fprintf(stdout, "empty\n"); }
[Aa][Tt]                             ;   // This rule will be ignored
[Tt][Hh][Ee]                         ;   // This rule will be ignored

[Dd][Ee][Ll]                        { fprintf(stdout, "del\n"); }
[Bb][Rr][Ee][Aa][Kk]               { fprintf(stdout, "break\n"); }


add         { fprintf(stdout, "add\n"); }
sub         { fprintf(stdout, "sub\n"); }
xor         { fprintf(stdout, "xor\n"); }
or          { fprintf(stdout, "or\n"); }
and         { fprintf(stdout, "and\n"); }
sll         { fprintf(stdout, "sll\n"); }
srl         { fprintf(stdout, "srl\n"); }
sra         { fprintf(stdout, "sra\n"); }
slt         { fprintf(stdout, "slt\n"); }
sltu        { fprintf(stdout, "sltu\n"); }
addi        { fprintf(stdout, "addi\n"); }
xori        { fprintf(stdout, "xori\n"); }
ori         { fprintf(stdout, "ori\n"); }
andi        { fprintf(stdout, "andi\n"); }
slli        { fprintf(stdout, "slli\n"); }
srli        { fprintf(stdout, "srli\n"); }
srai        { fprintf(stdout, "srai\n"); }
slti        { fprintf(stdout, "slti\n"); }
sltiu       { fprintf(stdout, "sltiu\n"); }
lb          { fprintf(stdout, "lb\n"); }
lh          { fprintf(stdout, "lh\n"); }
lw          { fprintf(stdout, "lw\n"); }
lbu         { fprintf(stdout, "lbu\n"); }
lhu         { fprintf(stdout, "lhu\n"); }
sb          { fprintf(stdout, "sb\n"); }
sh          { fprintf(stdout, "sh\n"); }
sw          { fprintf(stdout, "sw\n"); }
beq         { fprintf(stdout, "beq\n"); }
bne         { fprintf(stdout, "bne\n"); }
blt         { fprintf(stdout, "blt\n"); }
bge         { fprintf(stdout, "bge\n"); }
bltu        { fprintf(stdout, "bltu\n"); }
bgeu        { fprintf(stdout, "bgeu\n"); }
jal         { fprintf(stdout, "jal\n"); }
jalr        { fprintf(stdout, "jalr\n"); }
lui         { fprintf(stdout, "lui\n"); }


[a-zA-Z0-9_]+ { fprintf(stdout, "%s\n", yytext); }
[ \t\n] {;}
; {;}
\: ;
\, ;
\. ;
. { fprintf(stdout, "Unknown Character\n"); }
%%

int yywrap() {
    return 1;
}
int main(){
    yylex();
    return 0;
}