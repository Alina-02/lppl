/*****************************************************************************/
/**  Ejemplo de FLEX: S E M - 1             2018-2019 <jbenedi@dsic.upv.es> **/
/**  V. 20                                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include "header.h"
#include "bison.tab.h"

#define  retornar(x) {if (verbosidad) ECHO;}

%}
/*----------------------------------------------------------------------
  Dado que las funciones "input()" y "unput(c)" son costosas y no las
  utilizaremos, evitaremos que se generen automaticamente sus rutinas
  correspondientes desactivandolas mediante las siguientes opciones:
----------------------------------------------------------------------*/
%option noinput
%option nounput
/*----------------------------------------------------------------------
  Para mantener el numero de linea actual en la variable global yylineno
----------------------------------------------------------------------*/
%option yylineno

/*  Subsección de definiciones */

delimitador     [ \t\n]+
digito          [0-9]
entero          {digito}+
letra           [a-zA-Z]
constante       {entero} | .{entero} | {entero}. | {entero}.{entero}
identificador   {letra}({letra}|{digito}|_)*
comentario      \/\/.*

%%




{delimitador}   {if (verbosidad) ECHO ; }
"true"	 		    {if (verbosidad) ECHO ; retornar (TRUE_) ; }
"false"	 		      {if (verbosidad) ECHO ; retornar (FALSE_) ; }
"int"	 		      {if (verbosidad) ECHO ; retornar (INT_) ; }
"read"	 		      {if (verbosidad) ECHO ; retornar (READ_) ; }
"for"	 		      {if (verbosidad) ECHO ; retornar (FOR_) ; }
"if"	 		      {if (verbosidad) ECHO ; retornar (IF_) ; }
"print"	 		      {if (verbosidad) ECHO ; retornar (PRINT_) ; }
"bool"	 		      {if (verbosidad) ECHO ; retornar (BOOL_) ; }
{identificador}	 		      {if (verbosidad) ECHO ; retornar (ID_) ; }
{comentario}       {if(verbosidad) ECHO ;}

"=="            {if (verbosidad) ECHO ; retornar (IGUALCOMPARAR_) ; }
"&&"	 		      {if (verbosidad) ECHO ; retornar (AND_) ; }
"||"	 		      {if (verbosidad) ECHO ; retornar (OR_) ; }
"<"	 		      {if (verbosidad) ECHO ; retornar (MENQ_) ; }
">"	 		      {if (verbosidad) ECHO ; retornar (MAYQ_) ; }
","	 		      {if (verbosidad) ECHO ; retornar (COMA_) ; }
";"	 		      {if (verbosidad) ECHO ; retornar (PUNTOYCOMA_) ; }
"{"	 		      {if (verbosidad) ECHO ; retornar (ABRELLAVE_) ; }
"}"	 		      {if (verbosidad) ECHO ; retornar (CIERRALLAVE_) ; }
"["	 		      {if (verbosidad) ECHO ; retornar (ABRECORCHETE_) ; }
"]"	 		      {if (verbosidad) ECHO ; retornar (CIERRACORCHETE_) ; }
"!"	 		      {if (verbosidad) ECHO ; retornar (DIF_) ; }
"="	 		      {if (verbosidad) ECHO ; retornar (IGUALVARIABLE_) ; }
"+"		 		      {if (verbosidad) ECHO ; retornar (SUM_) ; }
"-"             {if (verbosidad) ECHO ; retornar (RES_) ; }
"*"             {if (verbosidad) ECHO ; retornar (MULT_) ; }
"/"             {if (verbosidad) ECHO ; retornar (DIV_) ; }
"("             {if (verbosidad) ECHO ; retornar (ABREPARENTESIS_) ; }
")"             {if (verbosidad) ECHO ; retornar (CIERRAPARENTESIS_) ; }
{entero}        {if (verbosidad) ECHO ; retornar (CTE_) ; }
.				{ yyerror("Caracter desconocido") ;}

%%
