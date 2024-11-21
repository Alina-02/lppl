/*****************************************************************************/
/**  Ejemplo de FLEX: S E M - 1             2018-2019 <jbenedi@dsic.upv.es> **/
/**  V. 20                                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include "header.h"
#include "bison.tab.h"
#include "libtds.h"
#define  retornar(x) {if (verbosidad) ECHO; return(x);}

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

delimitador     [ \t]+
digito          [0-9]
entero          {digito}+
letra           [a-zA-Z]
constante       {entero}|"."{entero}|{entero}"."|{entero}"."{entero}
identificador   {letra}({letra}|{digito}|_)*
comentario      \/\/.*

%%



"\n"            {if (verbosidad) ECHO ; yylineno()}
{delimitador}   {if (verbosidad) ECHO ; }


"true"	 		    {retornar (TRUE_) ; }
"false"	 		    {retornar (FALSE_) ; }
"int"	 		      {retornar (INT_) ; }
"read"	 		    {retornar (READ_) ; }
"for"	 		      {retornar (FOR_) ; }
"if"	 		      {retornar (IF_) ; }
"else"          {retornar (ELSE_) ;}
"print"	 		    {retornar (PRINT_) ; }
"bool"	 		    {retornar (BOOL_) ; }
"return"        {retornar (RETURN_) ; }


"="	 		      {retornar (IGUALVARIABLE_) ; }
"=="          {retornar (IGUALCOMPARAR_) ; }
"!="          {retornar (DIFCOMPARAR_) ; }
"&&"	 		    {retornar (AND_) ; }
"||"	 		    {retornar (OR_) ; }
"<"	 		      {retornar (MENQ_) ; }
"<="          {retornar (MENIGUQ_) ;}
">"	 		      {retornar (MAYQ_) ; }
">="          {retornar (MAYIGUQ_) ;}
","	 		      {retornar (COMA_) ; }
";"	 		      {retornar (PUNTOYCOMA_) ; }
"{"	 		      {retornar (ABRELLAVE_) ; }
"}"	 		      {retornar (CIERRALLAVE_) ; }
"["	 		      {retornar (ABRECORCHETE_) ; }
"]"	 		      {retornar (CIERRACORCHETE_) ; }
"!"	 		      {retornar (DIF_) ; }
"+"		 		    {retornar (SUM_) ; }
"-"           {retornar (RES_) ; }
"*"           {retornar (MULT_) ; }
"/"           {retornar (DIV_) ; }
"("           {retornar (ABREPARENTESIS_) ; }
")"           {retornar (CIERRAPARENTESIS_) ; }


{constante}        {yylval.cent = (int) atoy(yytext); retornar (CTE_) ; }
{identificador}	 	 {yylval.ident = strdup(yytext); retornar (ID_) ; }
{comentario}       {if(verbosidad) ECHO ;}

.				           { yyerror("Caracter desconocido") ;}

%%
