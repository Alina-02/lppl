// Declaraciones en C

%{
    #include <stdio.h>
    #include "header.h"
    #include "libtds.h"
%}

//Declaraciones en Bison

%union{
    int cent;
    char *ident;
}


%token RETURN_ READ_ PRINT_ IF_ FOR_
%token IGUALVARIABLE_ PUNTOYCOMA_ ABRECORCHETE_ CIERRACORCHETE_ ABREPARENTESIS_ CIERRAPARENTESIS_
%token ABRELLAVE_ CIERRALLAVE_ AND_ OR_ DIF_ MENQ_ MAYQ_ SUM_ RES_ MULT_ DIV_ COMA_ IGUALCOMPARAR_
%token ELSE_ MENIGUQ_ MAYIGUQ_ DIFCOMPARAR_ 

%token <ident> ID_ 
%token <cent> CTE_ TRUE_ FALSE_ INT_ BOOL_
%type <cent> tipoSimp declaFunc const
%type <cent> expre expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi


// Sección de reglas gramaticales

%%
programa :  {cargaContexto(niv);} 
            listDecla 
            {mostrarTdS();}
        ;

listDecla : decla 
    | listDecla decla
    ;

decla : declaVar
    | declaFunc
    ;

declaVar : tipoSimp ID_ PUNTOYCOMA_ {
                                        if(!insTdS($2, VARIABLE, $1, niv, dvar, -1)) 
                                            yyerror("Identificador repetido.");
                                        else    
                                            {dvar += TALLA_TIPO_SIMPLE;}
                                    }
    | tipoSimp ID_ IGUALVARIABLE_ const PUNTOYCOMA_ {
                                        if(!insTdS($2, VARIABLE, $1, niv, dvar, -1)){
                                            yyerror("Identificador repetido.");
                                        }else{
                                            dvar += TALLA_TIPO_SIMPLE;
                                            if($4 != $1){
                                                yyerror("Error de tipos");
                                            }
                                        }
                                    }
                                    
    | tipoSimp ID_ ABRECORCHETE_ CTE_ CIERRACORCHETE_ PUNTOYCOMA_ {
                                        if($4 <= 0){
                                            yyerror("Error en la talla del array");
                                        }
                                        else{
                                            int ref = insTdA($1, $4);
                                            if(!insTdS($2, VARIABLE, T_ARRAY, niv, dvar, ref)){
                                                
                                            yyerror("Identificador repetido.");

                                            }else{
                                                dvar += TALLA_TIPO_SIMPLE*$4;
                                            }
                                        }
                                    }
    ;

const : CTE_ {$$ = T_ENTERO;}
    | TRUE_  {$$ = T_LOGICO;}
    | FALSE_ {$$ = T_LOGICO;}
    ;

tipoSimp : INT_ {$$ = T_ENTERO;}
    | BOOL_     {$$ = T_LOGICO;}
    ;

declaFunc : tipoSimp ID_ ABREPARENTESIS_ paramForm CIERRAPARENTESIS_ 
    {   
        SIMB funcion = obtTdS($2);
        int ref;
        if(funcion.t == T_ERROR){
            ref = insTdD(-1,-1);
            insTdS($2,FUNCION,$1,niv+1,dvar,ref);
            dvar += TALLA_SEGENLACES;
        }
        else{
            yyerror("Funcion Repetida");
        }
    }
    bloque
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

expre : expreLogic 
    | ID_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado");
                                else if ($3 == T_ERROR) $$ = sim.t;
                                else if (!(((sim.t == T_ENTERO) && ($3 == T_ENTERO)) ||
                                            ((sim.t == T_LOGICO) && ($3 == T_LOGICO))))
                                    yyerror("Error de tipos en la intrucción de asignación");
                                else $$ = sim.t;
                                }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado");
                                else if(sim.t != T_ARRAY) yyerror("La variable debe ser de tipo array");
                                else{
                                    DIM array = obtTdA(sim.ref);
                                    if(array.telem != $6){
                                        yyerror("Error de tipos en la asignacion");
                                    }
                                    if($3 != T_ENTERO){
                                        yyerror("El indice del array debe ser entero");
                                    }else if($3 >= array.nelem){
                                        yyerror("Indice fuera de rango");
                                    }
                                }
                                }
    ;

expreLogic : expreIgual
    | expreLogic opLogic expreIgual {$$ = T_LOGICO;}
    ;

expreIgual : expreRel
    | expreIgual opIgual expreRel {$$ = T_LOGICO;}
    ;

expreRel : expreAd
    | expreRel opRel expreAd    {$$ = T_LOGICO;}
    ;

expreAd : expreMul
    | expreAd opAd expreMul     {$$ = T_ENTERO;}
    ;

expreMul : expreUna             
    | expreMul opMul expreUna   {$$ = T_ENTERO;}
    ;

expreUna : expreSufi 
    | opUna expreUna            {$$ = T_ENTERO;}
    ;

expreSufi : const
    | ABREPARENTESIS_ expre CIERRAPARENTESIS_ {$$ = $2;}
    | ID_ {         SIMB sim = obtTdS($1); 
                    if (sim.t == T_ERROR) yyerror("Objeto no declarado");
                    $$ = sim.t;
                    }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ {$$ = T_ENTERO;}
    | ID_ ABREPARENTESIS_ paramAct CIERRAPARENTESIS_ {$$ = T_ENTERO;}
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
