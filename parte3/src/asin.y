// Declaraciones en C

%{
    #include <stdio.h>
    #include <string.h>
    #include "header.h"
    #include "libtds.h"
    #include "libgci.h"
    int funcmain = 0;
    int functip = -1;
%}

//Declaraciones en Bison

%union{
    int cent;
    char *ident;
    DEFESTRUCT exp;
}


%token RETURN_ READ_ PRINT_ IF_ FOR_
%token IGUALVARIABLE_ PUNTOYCOMA_ ABRECORCHETE_ CIERRACORCHETE_ ABREPARENTESIS_ CIERRAPARENTESIS_
%token ABRELLAVE_ CIERRALLAVE_ AND_ OR_ DIF_ MENQ_ MAYQ_ SUM_ RES_ MULT_ DIV_ COMA_ IGUALCOMPARAR_
%token ELSE_ MENIGUQ_ MAYIGUQ_ DIFCOMPARAR_  
%token <ident> ID_ 
%token <cent> CTE_ TRUE_ FALSE_ INT_ BOOL_
%type <cent> tipoSimp declaFunc const listParamAct paramAct listParamForm paramForm
%type <exp> expre expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi expreOP
%type <cent> opLogic opIgual opRel opAd opMul opUna
// Sección de reglas gramaticales

%%

// inicializar las variables globales del compilador
// reservar espacio variables globales del programa
// emitir el salto al comienzo de la función "main"
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

// comprobar si el programa tiene "main"
// completar reserva espacio para variables globales programa
// completar salto al comienzo de la función "main"
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

// cargar los enlaces de control
// reserva de espacio para variables locales temporales
bloque : ABRELLAVE_ declaVarLocal listInst RETURN_ expre {
    if(functip == T_ERROR){yyerror("Error en la declaración de la función.");}
    else if (functip != $5.t){
        yyerror("El tipo retornado no coincide con la función.");
    }
    functip = -1;
    } PUNTOYCOMA_ CIERRALLAVE_
    ;

// completa reserva espacio para variables locales y temporales
// guardar valor de retorno
// libera el segmento de variables locales y temporales
// descarga de los enlaces de control
// emite fin si es "main" y return si no lo es
// mostrar la información de la función en la TdS
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
                                                                            if ($3.t == T_ERROR) yyerror("Objeto no declarado.");
                                                                            else if ($3.t != T_ENTERO) yyerror("La expresión del print debe ser entera.");
                                                                        } 
    ;

instSelec : IF_ ABREPARENTESIS_ expre {
                                        if($3.t == T_ERROR) yyerror("Expresión errónea.");
                                        else if ($3.t != T_LOGICO) yyerror("La expresión if debe ser de tipo lógico.");
                                    } 
            CIERRAPARENTESIS_ inst ELSE_ inst  
  ;

instIter : FOR_ ABREPARENTESIS_ expreOP PUNTOYCOMA_ expre { if($5.t == T_ERROR) yyerror("Objeto no declarado.");
                                                            else if($5.t != T_LOGICO) yyerror("La expresión for debe ser de tipo lógico.");
                                                        }
            PUNTOYCOMA_ expreOP CIERRAPARENTESIS_ inst   {
                                                                                                           
                                                            if($3.t!=T_VACIO){
                                                                if($3.t == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                            if($8!.t=T_VACIO){
                                                                if($8.t == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                        }
    ;

expreOP : {$$.t = T_VACIO;} 
    | expre {$$.t = $1;} 
    ;

expre : expreLogic 
    | ID_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                else if ($3 == T_ERROR) $$.t = sim.t;
                                else if ($3 == T_ARRAY) yyerror("La variable debe ser de tipo simple.");
                                else if (!(((sim.t == T_ENTERO) && ($3 == T_ENTERO)) ||
                                            ((sim.t == T_LOGICO) && ($3 == T_LOGICO))))
                                    yyerror("Error de tipos en la asignación.");
                                else $$.t = sim.t;
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
            $$.t=T_ERROR;
            yyerror("Error en la expresion lógica."); 
        }
        else $$.t = T_LOGICO;
        fprintf(stdout,"%d Hola", $2);
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
                                        $$.t = T_LOGICO;
                                    }
    ;

expreAd : expreMul
    | expreAd opAd expreMul     {
                                        if ($1 != $3|| $1 == T_ERROR|| $3 == T_ERROR  ) {yyerror("Error en expresion aditiva.");$$=T_ERROR; }
                                        $$.t = T_ENTERO;
                                    }
    ;

expreMul : expreUna             
    | expreMul opMul expreUna   {
                                        if ($1 != $3|| $1 == T_ERROR|| $3 == T_ERROR  ) {yyerror("Error en expresion multiplicativa.");$$=T_ERROR; }
                                        $$.t = T_ENTERO;
                                    }
    ;

expreUna : expreSufi 
    | opUna expreUna            {$$.t = T_LOGICO; if($2 != T_LOGICO) {yyerror("Error en la expresión unaria.");$$=T_ERROR;}}
    ;

expreSufi : const
    | ABREPARENTESIS_ expre CIERRAPARENTESIS_ {$$ = $2;}
    | ID_ {         SIMB sim = obtTdS($1); 
                    if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                    $$ = sim.t;
                    }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ {
            SIMB sim = obtTdS($1);
            if(sim.t == T_ARRAY){
                DIM dim = obtTdA(sim.ref);
                $$ = dim.telem;
            }
            else if(sim.t == T_ERROR){
                yyerror("Array no declarada");
                $$ = T_ERROR;
            }
            else{
                yyerror("La variable no es una array");
                $$ = T_ERROR;
            }
        } 
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

opLogic : AND_ {$$ = EMULT;}
    | OR_ {$$ = ESUM;}
    ;

opIgual : IGUALCOMPARAR_ {$$ = EIGUAL ;}
    | DIFCOMPARAR_ {$$ = EDIST ;}
    ;
 
opRel : MAYQ_ {$$ = EMAY ;}
    | MENQ_ {$$ = EMEN ;}
    | MAYIGUQ_ {$$ = EMAYEQ ;}
    | MENIGUQ_ {$$ = EMENEQ ;}
    ;

opAd : SUM_ {$$ = ESUM ;}
    | RES_ {$$ = EDIF ;}
    ;

opMul : MULT_ {$$ = EMULT ;}
    | DIV_ {$$ = EDIVI ;}
    ;

opUna : SUM_ {$$ = ESUM ;}
    | RES_ {$$ = EDIF ;}
    | DIF_ {$$ = ESIG ;}
    ;

%%
