/*****************************************************************************/
/**  Ejemplo de FLEX: S E M - 1             2018-2019 <jbenedi@dsic.upv.es> **/
/**  V. 20                                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include "header.h"
#include "asin.h"
#define  retornar(x) {if (verbosidad) ECHO; return(x);}

%}
%option noinput
%option nounput
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



"\n"            {if (verbosidad){ ECHO; fprintf(stdout,"%3d.- ", yylineno); }}
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


{constante}        {yylval.cent = atoi(yytext); retornar (CTE_) ; }
{identificador}	 	 {yylval.ident = strdup(yytext); retornar (ID_) ; }
{comentario}       {if(verbosidad) ECHO ;}

.				           { yyerror("Caracter desconocido") ;}

%%
