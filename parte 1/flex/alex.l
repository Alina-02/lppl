/*****************************************************************************/
/**  Ejemplo de FLEX: S E M - 1             2018-2019 <jbenedi@dsic.upv.es> **/
/**  V. 20                                                                  **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"

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

/* Sección de reglas, patrón - acción 
    Para mostrar el lexema renoconido por una regla se puede mostrar la
    variable de Flex yytex en la acción.
  Si una secuencia casa con un patrón, se escoge la secuencia más larga.
  Si tienen la misma longitud, se coge la primera.
*/

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

"&"	 		      {if (verbosidad) ECHO ; retornar (AND_) ; }
"|"	 		      {if (verbosidad) ECHO ; retornar (OR_) ; }
"<"	 		      {if (verbosidad) ECHO ; retornar (MENQ_) ; }
">"	 		      {if (verbosidad) ECHO ; retornar (MAYQ_) ; }
","	 		      {if (verbosidad) ECHO ; retornar (COMA_) ; }
";"	 		      {if (verbosidad) ECHO ; retornar (PUNTOYCOMA_) ; }
"{"	 		      {if (verbosidad) ECHO ; retornar (ABRELLAVE_) ; }
"}"	 		      {if (verbosidad) ECHO ; retornar (CIERRALLAVE_) ; }
"["	 		      {if (verbosidad) ECHO ; retornar (ABRECORCHETE_) ; }
"]"	 		      {if (verbosidad) ECHO ; retornar (CIERRACORCHETE_) ; }
"!"	 		      {if (verbosidad) ECHO ; retornar (DIF_) ; }
"="	 		      {if (verbosidad) ECHO ; retornar (IGUAL_) ; }
"+"		 		      {if (verbosidad) ECHO ; retornar (SUM_) ; }
"-"             {if (verbosidad) ECHO ; retornar (RES_) ; }
"*"             {if (verbosidad) ECHO ; retornar (MULT_) ; }
"/"             {if (verbosidad) ECHO ; retornar (DIV_) ; }
"("             {if (verbosidad) ECHO ; retornar (ABREPARENTESIS_) ; }
")"             {if (verbosidad) ECHO ; retornar (CIERRAPARENTESIS_) ; }
{entero}        {if (verbosidad) ECHO ; retornar (CTE_) ; }
.				{ yyerror("Caracter desconocido") ;}

%%
int verbosidad = FALSE; 

/* Sección de funciones de usuario 
    Si se utiliza alguna función en la sección de reglas, hay que 
    incluir la cabecera en el preámbulo C de la sección de definiciones.
    Debe haber una función main. También se puede escribir en un fichero
    a parte pero haría falta añadir el nombre del fichero en la orden
    de llamada para que el compilador.
*/

/*****************************************************************************/
void yyerror(const char *msg){
/*  Tratamiento de errores.                                                  */
  fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg);
}

/*****************************************************************************/
int main(int argc, char **argv) {
	int i, n=1 ;

	for (i=1; i<argc; ++i)
      if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
	if (argc == n+1)
      if ((yyin = fopen (argv[n], "r")) == NULL)
      	fprintf (stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
      else yylex ();
	else fprintf (stderr, "Uso: cmc [-v] fichero\n");

	return (0);
} 

/*****************************************************************************/
