// Declaraciones en C

%{
    #include <stdio.h>
    #include <string.h>
    #include "header.h"
    #include "libtds.h"
    int funcmain = 0;
    int functip = -1;
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
%type <cent> tipoSimp declaFunc const listParamAct paramAct listParamForm paramForm
%type <cent> expre expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi expreOP

// Sección de reglas gramaticales

%%
programa :  {dvar = 0; niv = 0;cargaContexto(niv);} 
            listDecla 
            {   if(funcmain == 0){
                yyerror("El programa no tiene función main.");
            }
            else if (funcmain > 1){
                yyerror("El programa tiene mas de una función main.");
            }

            }
        ;

listDecla : decla 
    | listDecla decla
    ;

decla : declaVar
    | declaFunc
    ;

declaVar : tipoSimp ID_ PUNTOYCOMA_ {
                                        if(!insTdS($2, VARIABLE, $1, niv, dvar, -1)) 
                                            yyerror("Identificador de variable repetido.");
                                        else    
                                            {dvar += TALLA_TIPO_SIMPLE;}
                                    }
    | tipoSimp ID_ IGUALVARIABLE_ const PUNTOYCOMA_ {
                                        if(!insTdS($2, VARIABLE, $1, niv, dvar, -1)){
                                            yyerror("Identificador de variable repetido.");
                                        }else{
                                            dvar += TALLA_TIPO_SIMPLE;
                                            if($4 != $1){
                                                yyerror("Error de tipos en la inicialización de la variable.");
                                            }
                                        }
                                    }
                                    
    | tipoSimp ID_ ABRECORCHETE_ CTE_ CIERRACORCHETE_ PUNTOYCOMA_ {
                                        if($4 <= 0){
                                            yyerror("Talla inapropiada del array.");
                                        }
                                        else{
                                            int ref = insTdA($1, $4);
                                            if(!insTdS($2, VARIABLE, T_ARRAY, niv, dvar, ref)){
                                                
                                            yyerror("Identificador del array repetido.");

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

declaFunc :tipoSimp ID_ {
                            cargaContexto(1);
                            niv = 1;
                            $<cent>$ = dvar;
                            dvar = 0;
                        }
ABREPARENTESIS_ paramForm CIERRAPARENTESIS_ {
                                                dvar = 0;
                                                functip = $1;
                                                if(!insTdS($2,FUNCION,$1,0,0,$5)){
                                                    yyerror("Identificador de función repetido.");
                                                    functip = T_ERROR;
                                                }
                                                if(strcmp($2,"main") == 0){
                                                    funcmain++;
                                            }
    
} bloque {
            if(verTdS)mostrarTdS();
            descargaContexto(niv);
            niv = 0;
            dvar = $<cent>3;
        }
    ;

paramForm :         {$$ = insTdD(-1,T_VACIO);}
    | listParamForm
    ;

listParamForm : tipoSimp ID_   {
    $$ = insTdD(-1,$1);dvar -= TALLA_TIPO_SIMPLE + TALLA_SEGENLACES;
    if(!insTdS($2,PARAMETRO,$1,niv,dvar,-1)) yyerror("Identificador de parámetro repetido.");
    }
    | tipoSimp ID_ COMA_ listParamForm {
    $$ = insTdD($4,$1); dvar -= TALLA_TIPO_SIMPLE;
    if(!insTdS($2,PARAMETRO,$1,niv,dvar,-1)) yyerror("Identificador de parámetro repetido.");
    }
    ;

bloque : ABRELLAVE_ declaVarLocal listInst RETURN_ expre {
    if(functip == T_ERROR){yyerror("Error en la declaración de la función.");}
    else if (functip != $5){
        yyerror("El tipo retornado no coincide con la función.");
    }
    functip = -1;
    } PUNTOYCOMA_ CIERRALLAVE_
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

instEntSal : READ_ ABREPARENTESIS_ ID_ CIERRAPARENTESIS_ PUNTOYCOMA_    {
                                                                            SIMB sim = obtTdS($3);
                                                                            if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                                                            else if (sim.t != T_ENTERO) yyerror("El argumento del read debe ser entero.");
                                                                        } 
    | PRINT_ ABREPARENTESIS_ expre CIERRAPARENTESIS_ PUNTOYCOMA_        {
                                                                            if ($3 == T_ERROR) yyerror("Objeto no declarado.");
                                                                            else if ($3 != T_ENTERO) yyerror("La expresión del print debe ser entera.");
                                                                        } 
    ;

instSelec : IF_ ABREPARENTESIS_ expre {
                                        if($3 == T_ERROR) yyerror("Expresión errónea.");
                                        else if ($3 != T_LOGICO) yyerror("La expresión if debe ser de tipo lógico.");
                                    } 
            CIERRAPARENTESIS_ inst ELSE_ inst  
  ;

instIter : FOR_ ABREPARENTESIS_ expreOP PUNTOYCOMA_ expre { if($5 == T_ERROR) yyerror("Objeto no declarado.");
                                                            else if($5 != T_LOGICO) yyerror("La expresión for debe ser de tipo lógico.");
                                                        }
            PUNTOYCOMA_ expreOP CIERRAPARENTESIS_ inst   {
                                                                                                           
                                                            if($3!=T_VACIO){
                                                                if($3 == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                            if($8!=T_VACIO){
                                                                if($8 == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                        }
    ;

expreOP : {$$ = T_VACIO;} 
    | expre {$$ = $1;} 
    ;

expre : expreLogic 
    | ID_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                else if ($3 == T_ERROR) $$ = sim.t;
                                else if ($3 == T_ARRAY) yyerror("La variable debe ser de tipo simple.");
                                else if (!(((sim.t == T_ENTERO) && ($3 == T_ENTERO)) ||
                                            ((sim.t == T_LOGICO) && ($3 == T_LOGICO))))
                                    yyerror("Error de tipos en la asignación.");
                                else $$ = sim.t;
                                }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                else if(sim.t != T_ARRAY) yyerror("La variable debe ser de tipo array.");
                                else{
                                    DIM array = obtTdA(sim.ref);
                                    if(array.telem != $6){
                                        yyerror("Error de tipos en la asignacion a un array.");
                                    }
                                    if($3 != T_ENTERO){
                                        yyerror("El indice del array debe ser entero.");
                                    }else if($3 >= array.nelem){
                                        yyerror("Indice fuera de rango.");
                                    }
                                }
                                }
    ;

expreLogic : expreIgual
    | expreLogic opLogic expreIgual {
        if($1!=T_LOGICO|| $3!=T_LOGICO ) {
            $$=T_ERROR;
            yyerror("Error en la expresion lógica."); 
        }
        else $$ = T_LOGICO;
    }
    ;

expreIgual : expreRel
    | expreIgual opIgual expreRel {
                                        if ($1 != $3|| $1 != T_ENTERO || $3 != T_ENTERO  ) {yyerror("Error en expresion de igualdad."); $$=T_ERROR;};
                                    }
    ;

expreRel : expreAd
    | expreRel opRel expreAd    {
                                        if ($1 != $3|| $1 == T_ERROR|| $3 == T_ERROR  ) {yyerror("Error en expresion relacional.");$$=T_ERROR; }
                                        $$ = T_LOGICO;
                                    }
    ;

expreAd : expreMul
    | expreAd opAd expreMul     {
                                        if ($1 != $3|| $1 == T_ERROR|| $3 == T_ERROR  ) {yyerror("Error en expresion aditiva.");$$=T_ERROR; }
                                        $$ = T_ENTERO;
                                    }
    ;

expreMul : expreUna             
    | expreMul opMul expreUna   {
                                        if ($1 != $3|| $1 == T_ERROR|| $3 == T_ERROR  ) {yyerror("Error en expresion multiplicativa.");$$=T_ERROR; }
                                        $$ = T_ENTERO;
                                    }
    ;

expreUna : expreSufi 
    | opUna expreUna            {$$ = T_LOGICO; if($2 != T_LOGICO) {yyerror("Error en la expresión unaria.");$$=T_ERROR;}}
    ;

expreSufi : const
    | ABREPARENTESIS_ expre CIERRAPARENTESIS_ {$$ = $2;}
    | ID_ {         SIMB sim = obtTdS($1); 
                    if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                    $$ = sim.t;
                    }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ {$$ = T_ENTERO;} 
    | ID_ ABREPARENTESIS_ paramAct CIERRAPARENTESIS_ {SIMB sim = obtTdS($1); 
                                                    if (sim.t == T_ERROR){
                                                        yyerror("Función no declarada.");
                                                        $$ = T_ERROR;
                                                    } 
                                                    else if(sim.t == T_ARRAY){
                                                        yyerror("La variable no es una función.");
                                                        $$ = T_ERROR;
                                                    }
                                                    else if(sim.ref == -1){
                                                        yyerror("La variable no es una función.");
                                                        $$ = T_ERROR;
                                                    }
                                                    else if(!cmpDom($3,sim.ref)){
                                                        yyerror("Número o tipo de parámetros no coincide.");
                                                        $$ = T_ERROR;
                                                    }else{
                                                        $$ = sim.t;
                                                        }
                                                    }
    ;

paramAct :          {$$ = insTdD(-1,T_VACIO);}
    | listParamAct
    ;

listParamAct : expre    {$$ = insTdD(-1,$1);}
    | expre COMA_ listParamAct {$$ = insTdD($3,$1);}
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
