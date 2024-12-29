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
    int lista[5];
}


%token RETURN_ READ_ PRINT_ IF_ FOR_
%token IGUALVARIABLE_ PUNTOYCOMA_ ABRECORCHETE_ CIERRACORCHETE_ ABREPARENTESIS_ CIERRAPARENTESIS_
%token ABRELLAVE_ CIERRALLAVE_ AND_ OR_ DIF_ MENQ_ MAYQ_ SUM_ RES_ MULT_ DIV_ COMA_ IGUALCOMPARAR_
%token ELSE_ MENIGUQ_ MAYIGUQ_ DIFCOMPARAR_  
%token <ident> ID_ 
%token <cent> CTE_ TRUE_ FALSE_ INT_ BOOL_
%type <cent> tipoSimp listParamAct paramAct listParamForm paramForm decla listDecla declaFunc
%type <exp> expre expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi expreOP const bloque
%type <cent> opLogic opIgual opRel opAd opMul opUna
// Sección de reglas gramaticales

%%

// inicializar las variables globales del compilador
// reservar espacio variables globales del programa
// emitir el salto al comienzo de la función "main"
programa :  {
            dvar = 0; niv = 0;
            cargaContexto(niv);
            $<lista>$[0] = creaLans(si);
            emite(INCTOP,crArgNul(),crArgNul(),crArgEnt(0));
            $<lista>$[1] = creaLans(si);
            emite(GOTOS,crArgNul(),crArgNul(),crArgEnt(0));

            } 
            listDecla 
            {   
                if(funcmain == 0){
                yyerror("El programa no tiene función main.");
            }
            else if (funcmain > 1){
                yyerror("El programa tiene mas de una función main.");
            }
                completaLans($<lista>1[0],crArgEnt(dvar));
                completaLans($<lista>1[1],crArgEtq($2));
            }
        ;

// comprobar si el programa tiene "main"
// completar reserva espacio para variables globales programa
// completar salto al comienzo de la función "main"
listDecla : decla 
    | listDecla decla {$$ = $1 + $2;}
    ;

decla : declaVar {$$ = 0;}
    | declaFunc { $$ = $1;}
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
                                            if($4.t != $1){
                                                yyerror("Error de tipos en la inicialización de la variable.");
                                            }
                                        }
                                        SIMB sim = obtTdS($2);
                                        emite(EASIG,crArgPos($4.n,$4.d),crArgNul(),crArgPos(sim.n,sim.d));
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

const : CTE_ {
                $$.t = T_ENTERO; $$.n=niv; $$.d=creaVarTemp();
                emite(EASIG, crArgEnt($1),crArgNul(),crArgPos($$.n,$$.d));
            }
    | TRUE_  {$$.t = T_LOGICO; $$.n=niv; $$.d=creaVarTemp();
                emite(EASIG, crArgEnt(1),crArgNul(),crArgPos($$.n,$$.d));
    
    }
    | FALSE_ {$$.t = T_LOGICO; $$.n=niv; $$.d=creaVarTemp();
                emite(EASIG, crArgEnt(0),crArgNul(),crArgPos($$.n,$$.d));
    }
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
ABREPARENTESIS_ paramForm CIERRAPARENTESIS_ {   $<lista>$[0] = 0;
                                                dvar = 0;
                                                functip = $1;
                                                if(!insTdS($2,FUNCION,$1,0,si,$5)){
                                                    yyerror("Identificador de función repetido.");
                                                    functip = T_ERROR;
                                                }
                                                if(strcmp($2,"main") == 0){
                                                    $<lista>$[0] = si;
                                                    funcmain++;
                                                }
                                                emite(PUSHFP,crArgNul(),crArgNul(),crArgNul());
                                                emite(FPTOP,crArgNul(),crArgNul(),crArgNul());
                                                $<lista>$[1] = creaLans(si);
                                                emite(INCTOP,crArgNul(),crArgNul(),crArgNul());

    
} bloque {

            completaLans($<lista>7[1],crArgEnt(dvar));
            $$ = $<lista>7[0];
            INF inf = obtTdD($5);
            emite(EASIG,crArgPos($8.n,$8.d),crArgNul(),crArgPos(niv,-(TALLA_TIPO_SIMPLE+TALLA_SEGENLACES+inf.tsp)));               
            emite(TOPFP,crArgNul(),crArgNul(),crArgNul());
            emite(FPPOP,crArgNul(),crArgNul(),crArgNul());
            if($<lista>7[0] != 0){
                emite(FIN,crArgNul(),crArgNul(),crArgNul());
            }else{
                emite(RET,crArgNul(),crArgNul(),crArgNul());
            }
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
    } PUNTOYCOMA_ CIERRALLAVE_{
        $$.d = $5.d;
        $$.n = $5.n;
    }
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
                                                                            emite(EWRITE,crArgNul(),crArgNul(),crArgPos($3.n,$3.d));
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
                                                                                                           
                                                            if($3.t !=T_VACIO){
                                                                if($3.t == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                            if($8.t != T_VACIO){
                                                                if($8.t == T_ARRAY) yyerror("La expresión debe ser de tipo simple.");
                                                            }
                                                        }
    ;

expreOP : {$$.t = T_VACIO;} 
    | expre {$$.t = $1.t;} 
    ;

expre : expreLogic 
    | ID_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                else if ($3.t == T_ERROR) $$.t = sim.t;
                                else if ($3.t == T_ARRAY) yyerror("La variable debe ser de tipo simple.");
                                else if (!(((sim.t == T_ENTERO) && ($3.t == T_ENTERO)) ||
                                            ((sim.t == T_LOGICO) && ($3.t == T_LOGICO))))
                                    yyerror("Error de tipos en la asignación.");
                                else $$.t = sim.t;

                                $$.d = sim.d;
                                $$.n = sim.n;
                                emite(EASIG, crArgPos(niv, $3.d), crArgNul(), crArgPos(sim.n, sim.d));   
                                }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ IGUALVARIABLE_ expre {SIMB sim = obtTdS($1); 
                                if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                                else if(sim.t != T_ARRAY) yyerror("La variable debe ser de tipo array.");
                                else{
                                    DIM array = obtTdA(sim.ref);
                                    if(array.telem != $6.t){
                                        yyerror("Error de tipos en la asignacion a un array.");
                                    }
                                    if($3.t != T_ENTERO){
                                        yyerror("El indice del array debe ser entero.");
                                    }
                                }

                                $$.d = sim.d;
                                $$.n = sim.n;
                                emite(EVA, crArgPos(sim.n, sim.d) , crArgPos($3.n, $3.d), crArgPos($6.n, $6.d));
                                }
    ;

expreLogic : expreIgual 
    | expreLogic opLogic expreIgual {
        if($1.t!=T_LOGICO|| $3.t !=T_LOGICO ) {
            $$.t=T_ERROR;
            yyerror("Error en la expresion lógica."); 
        }
        else $$.t = T_LOGICO;
        fprintf(stdout,"%d Hola", $2);
    }
    ;

expreIgual : expreRel
    | expreIgual opIgual expreRel {
                                        if ($1.t != $3.t || $1.t  != T_ENTERO || $3.t  != T_ENTERO  ) {yyerror("Error en expresion de igualdad."); $$.t=T_ERROR;};
                                    }
    ;

expreRel : expreAd
    | expreRel opRel expreAd    {
                                        if ($1.t != $3.t || $1.t  == T_ERROR|| $3.t == T_ERROR  ) {yyerror("Error en expresion relacional.");$$.t=T_ERROR; }
                                        $$.t = T_LOGICO;
                                    }
    ;

expreAd : expreMul
    | expreAd opAd expreMul     {
                                        if ($1.t  != $3.t || $1.t  == T_ERROR|| $3.t  == T_ERROR  ) {yyerror("Error en expresion aditiva.");$$.t=T_ERROR; }
                                        $$.t = T_ENTERO;
                                    }
    ;

expreMul : expreUna             
    | expreMul opMul expreUna   {
                                        if ($1.t  != $3.t || $1.t  == T_ERROR|| $3.t  == T_ERROR  ) {yyerror("Error en expresion multiplicativa.");$$.t=T_ERROR; }
                                        $$.t = T_ENTERO;
                                    }
    ;

expreUna : expreSufi 
    | opUna expreUna            {$$.t = T_LOGICO; if($2.t != T_LOGICO) {yyerror("Error en la expresión unaria.");$$.t=T_ERROR;}}
    ;

expreSufi : const
    | ABREPARENTESIS_ expre CIERRAPARENTESIS_ {$$  = $2;}
    | ID_ {         SIMB sim = obtTdS($1); 
                    if (sim.t == T_ERROR) yyerror("Objeto no declarado.");
                    $$.t = sim.t;
                    $$.d=sim.d;
                    $$.n=sim.n;
                    }
    | ID_ ABRECORCHETE_ expre CIERRACORCHETE_ {
            SIMB sim = obtTdS($1);
            if(sim.t == T_ARRAY){
                DIM dim = obtTdA(sim.ref);
                $$.t = dim.telem;
            }
            else if(sim.t == T_ERROR){
                yyerror("Array no declarada");
                $$.t = T_ERROR;
            }
            else{
                yyerror("La variable no es una array");
                $$.t = T_ERROR;
            }
            $$.d = creaVarTemp();
            $$.n = niv;
            emite(EAV, crArgPos(sim.n,sim.d),crArgPos($3.n,$3.d) ,crArgPos(niv,$$.d));
        } 
    | ID_ {
            emite(INCTOP,crArgNul(),crArgNul(),crArgEnt(1));
        }
    ABREPARENTESIS_ paramAct CIERRAPARENTESIS_ {SIMB sim = obtTdS($1); 
                                                    if (sim.t == T_ERROR){
                                                        yyerror("Función no declarada.");
                                                        $$.t = T_ERROR;
                                                    } 
                                                    else if(sim.t == T_ARRAY){
                                                        yyerror("La variable no es una función.");
                                                        $$.t = T_ERROR;
                                                    }
                                                    else if(sim.ref == -1){
                                                        yyerror("La variable no es una función.");
                                                        $$.t = T_ERROR;
                                                    }
                                                    else if(!cmpDom($4,sim.ref)){
                                                        yyerror("Número o tipo de parámetros no coincide.");
                                                        $$.t = T_ERROR;
                                                    }else{
                                                        $$.t = sim.t;
                                                        $$.n = niv;
                                                        $$.d = creaVarTemp();
                                                        INF inf = obtTdD(sim.ref);
                                                        emite(CALL,crArgNul(),crArgNul(),crArgEtq(sim.d));
                                                        emite(DECTOP,crArgNul(),crArgNul(),crArgEnt(inf.tsp));
                                                        emite(EPOP,crArgNul(),crArgNul(),crArgPos($$.n,$$.d));

                                                        }
                                                    }
    ;

paramAct :          {$$ = insTdD(-1,T_VACIO);}
    | listParamAct
    ;

listParamAct : expre    {   $$ = insTdD(-1,$1.t);
                            emite(EPUSH,crArgNul(),crArgNul(),crArgNul($1.d));
                        }
    | expre COMA_ listParamAct {
            $$ = insTdD($3,$1.t);
            emite(EPUSH,crArgNul(),crArgNul(),crArgNul($1.d));
    }
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
