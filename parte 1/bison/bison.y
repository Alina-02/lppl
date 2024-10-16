// Declaraciones en C

%{
    #include <stdio.h>
    #include "header.h"
%}

//Declaraciones en Bison

%token <valor> ID CTE TRUE FALSE INT BOOL RETURN READ PRINT IF FOR

// Sección de reglas gramaticales

%%
programa : listDecla
        ;

listDecla : decla 
        | listDecla decla
    ;

decla : declaVar
    | declaFunc
    ;

declaVar : tipoSimp ID ;
    | tipoSimp ID = const ;
    | tipoSimp ID [ CTE ] ;
    ;

const : CTE
    | TRUE
    | FALSE
    ;

tipoSimp : INT
    | BOOL
    ;

declaFunc : tipoSimp ID ( paramForm ) bloque
    ;

paramForm : 
    | listParamForm
    ;

listParamForm : tipoSimp ID 
    | tipoSimp ID , listParamForm
    ;

bloque : { declaVarLocal listInst RETURN expre ; }
    ;

declaVarLocal : 
    | declaVarLocal declaVar
    ;

listInst : 
    | listInst inst 
    ;

inst : { listInst }
    | instExpre
    | instEntSal
    | instSelec
    | instIter
    ;

instExpre : expre ;
    | ;
    ;

instEntSal : READ ( ID ) ;
    | PRINT ( expre ) ;
    ;

instSelec : IF ( expre ) inst ELSE inst
    ;

instIter : FOR ( expreOP ; expre ; expreOP) inst
    ;

expreOP : 
    | expre
    ;

expre : expreLogic 
    | ID = expre
    | ID [ expre ] = expre
    ;

expreLogic : expreIgual
    | expreLogic opLogic expreIgual
    ;

expreIgual : expreRel
    | expreIgual opIgual expreRel
    ;

expreRel : expreAd 
    | expreRel opRel expreAd
    ;

expreAd : expreMul
    | expreAd opAd expreMul
    ;

expreMul : expreUna
    | expreMul opMul expreUna
    ;

expreUna : expreSufi 
    | opUna expreUna
    ;

expreSufi : const 
    | ( expre )
    | ID
    | ID [ expre ]
    | ID ( paramAct )
    ;

paramAct : 
    | listParamAct
    ;

listParamAct : expre
    | expre , listParamAct
    ;

opLogic : &&
    | ||
    ;

opIgual : ==
    | !=
    ;

opRel : >
    | <
    | >=
    | <=
    ;

opAd : +
    | -
    ;

opMul : *
    | /
    ;

opUna : +
    | -
    | !
    ;

%%
void yyerror(const char *msg) {
fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg);
}
int main(int argc, char **argv) {
int i, n=1 ;
for (i=1; i<argc; ++i)
if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
if (argc == n+1)
if ((yyin = fopen (argv[n], "r")) == NULL)
fprintf (stderr, "El fichero ’%s’ no es valido\n", argv[n]) ;
else yyparse ();
else fprintf (stderr, "Uso: cmc [-v] fichero\n");
return (0);
}