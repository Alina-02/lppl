/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    RETURN_ = 258,                 /* RETURN_  */
    READ_ = 259,                   /* READ_  */
    PRINT_ = 260,                  /* PRINT_  */
    IF_ = 261,                     /* IF_  */
    FOR_ = 262,                    /* FOR_  */
    IGUALVARIABLE_ = 263,          /* IGUALVARIABLE_  */
    PUNTOYCOMA_ = 264,             /* PUNTOYCOMA_  */
    ABRECORCHETE_ = 265,           /* ABRECORCHETE_  */
    CIERRACORCHETE_ = 266,         /* CIERRACORCHETE_  */
    ABREPARENTESIS_ = 267,         /* ABREPARENTESIS_  */
    CIERRAPARENTESIS_ = 268,       /* CIERRAPARENTESIS_  */
    ABRELLAVE_ = 269,              /* ABRELLAVE_  */
    CIERRALLAVE_ = 270,            /* CIERRALLAVE_  */
    AND_ = 271,                    /* AND_  */
    OR_ = 272,                     /* OR_  */
    DIF_ = 273,                    /* DIF_  */
    MENQ_ = 274,                   /* MENQ_  */
    MAYQ_ = 275,                   /* MAYQ_  */
    SUM_ = 276,                    /* SUM_  */
    RES_ = 277,                    /* RES_  */
    MULT_ = 278,                   /* MULT_  */
    DIV_ = 279,                    /* DIV_  */
    COMA_ = 280,                   /* COMA_  */
    IGUALCOMPARAR_ = 281,          /* IGUALCOMPARAR_  */
    ELSE_ = 282,                   /* ELSE_  */
    MENIGUQ_ = 283,                /* MENIGUQ_  */
    MAYIGUQ_ = 284,                /* MAYIGUQ_  */
    DIFCOMPARAR_ = 285,            /* DIFCOMPARAR_  */
    ID_ = 286,                     /* ID_  */
    CTE_ = 287,                    /* CTE_  */
    TRUE_ = 288,                   /* TRUE_  */
    FALSE_ = 289,                  /* FALSE_  */
    INT_ = 290,                    /* INT_  */
    BOOL_ = 291                    /* BOOL_  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 14 "src/asin.y"

    int cent;
    char *ident;

#line 105 "asin.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_ASIN_H_INCLUDED  */
