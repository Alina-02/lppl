// Declaraciones en C

%{
    #include <stdio.h>
    #include "header.h"
%}

//Declaraciones en Bison

%token ID_ CTE_ TRUE_ FALSE_ INT_ BOOL_ RETURN_ READ_ PRINT_ IF_ FOR_
%token IGUALVARIABLE_ PUNTOYCOMA_ ABRECORCHETE_ CIERRACORCHETE_ ABREPARENTESIS_ CIERRAPARENTESIS_
%token ABRELLAVE_ CIERRALLAVE_ AND_ OR_ DIF_ MENQ_ MAYQ_ SUM_ RES_ MULT_ DIV_ COMA_ IGUALCOMPARAR_
%token ELSE_ MENIGUQ_ MAYIGUQ_ DIFCOMPARAR_ 

%union{
    int cent;
    chat *ident;
}

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

declaVar : tipoSimp ID_ PUNTOYCOMA_
    | tipoSimp ID_ IGUALVARIABLE_ const PUNTOYCOMA_
    | tipoSimp ID_ ABRECORCHETE_ CTE_ CIERRACORCHETE_ PUNTOYCOMA_
    ;

const : CTE_ {$$.tipo = T_ENTERO;}
    | TRUE_ {$$.tipo = T_LOGICO;}
    | FALSE_ {$$.tipo = T_LOGICO;}
    ;

tipoSimp : INT_
    | BOOL_
    ;

declaFunc : tipoSimp ID_ ABREPARENTESIS_ paramForm CIERRAPARENTESIS_ bloque
    ;

paramForm : 
    | listParamForm
    ;

listParamForm : tipoSimp ID_ 
    | tipoSimp ID_ COMA_ listParamForm
    ;

bloque : ABRELLAVE_ declaVarLocal listInst RETURN_ expre PUNTOYCOMA_ CIERRALLAVE_
    ;

declaVarLocal : 
    | declaVarLocal declaVar
    ;

listInst : 
    | listInst inst 
    ;

inst : ABRELLAVE_ listInst CIERRALLAVE_
    | instExpre
    | instEntSal
    | instSelec
    | instIter
    ;

instExpre : expre PUNTOYCOMA_
    | PUNTOYCOMA_
    ;

instEntSal : READ_ ABREPARENTESIS_ ID_ CIERRAPARENTESIS_ PUNTOYCOMA_
    | PRINT_ ABREPARENTESIS_ expre CIERRAPARENTESIS_ PUNTOYCOMA_
    ;

instSelec : IF_ ABREPARENTESIS_ expre CIERRAPARENTESIS_ inst ELSE_ inst
    ;

instIter : FOR_ ABREPARENTESIS_ expreOP PUNTOYCOMA_ expre PUNTOYCOMA_ expreOP CIERRAPARENTESIS_ inst
    ;

expreOP : 
    | expre
    ;

expre : expreLogic {$$.tipo = $1.tipo;}
    | ID_ IGUALVARIABLE_ expre
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ IGUALVARIABLE_ expre
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

expreAd : expreMul {$$.tipo = $1.tipo;}
    | expreAd opAd expreMul
    ;

expreMul : expreUna {$$.tipo = $1.tipo;}
    | expreMul opMul expreUna
    ;

expreUna : expreSufi 
    | opUna expreUna
    ;

expreSufi : const 
    | ABREPARENTESIS_ expre CIERRAPARENTESIS_
    | ID_
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_
    | ID_ ABREPARENTESIS_ paramAct CIERRAPARENTESIS_
    ;

paramAct : 
    | listParamAct
    ;

listParamAct : expre
    | expre COMA_ listParamAct
    ;

opLogic : AND_
    | OR_
    ;

opIgual : IGUALCOMPARAR_
    | DIFCOMPARAR_
    ;

opRel : MAYQ_
    | MENQ_
    | MAYIGUQ_
    | MENIGUQ_
    ;

opAd : SUM_
    | RES_
    ;

opMul : MULT_ 
    | DIV_
    ;

opUna : SUM_ 
    | RES_ 
    | DIF_ 
    ;

%%
