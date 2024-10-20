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

#ifndef YY_YY_BISON_TAB_H_INCLUDED
# define YY_YY_BISON_TAB_H_INCLUDED
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
    ID_ = 258,                     /* ID_  */
    CTE_ = 259,                    /* CTE_  */
    TRUE_ = 260,                   /* TRUE_  */
    FALSE_ = 261,                  /* FALSE_  */
    INT_ = 262,                    /* INT_  */
    BOOL_ = 263,                   /* BOOL_  */
    RETURN_ = 264,                 /* RETURN_  */
    READ_ = 265,                   /* READ_  */
    PRINT_ = 266,                  /* PRINT_  */
    IF_ = 267,                     /* IF_  */
    FOR_ = 268,                    /* FOR_  */
    IGUALVARIABLE_ = 269,          /* IGUALVARIABLE_  */
    PUNTOYCOMA_ = 270,             /* PUNTOYCOMA_  */
    ABRECORCHETE_ = 271,           /* ABRECORCHETE_  */
    CIERRACORCHETE_ = 272,         /* CIERRACORCHETE_  */
    ABREPARENTESIS_ = 273,         /* ABREPARENTESIS_  */
    CIERRAPARENTESIS_ = 274,       /* CIERRAPARENTESIS_  */
    ABRELLAVE_ = 275,              /* ABRELLAVE_  */
    CIERRALLAVE_ = 276,            /* CIERRALLAVE_  */
    AND_ = 277,                    /* AND_  */
    OR_ = 278,                     /* OR_  */
    DIF_ = 279,                    /* DIF_  */
    MENQ_ = 280,                   /* MENQ_  */
    MAYQ_ = 281,                   /* MAYQ_  */
    SUM_ = 282,                    /* SUM_  */
    RES_ = 283,                    /* RES_  */
    MULT_ = 284,                   /* MULT_  */
    DIV_ = 285,                    /* DIV_  */
    COMA_ = 286,                   /* COMA_  */
    IGUALCOMPARAR_ = 287,          /* IGUALCOMPARAR_  */
    ELSE_ = 288,                   /* ELSE_  */
    MENIGUQ_ = 289,                /* MENIGUQ_  */
    MAYIGUQ_ = 290,                /* MAYIGUQ_  */
    DIFCOMPARAR_ = 291             /* DIFCOMPARAR_  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_BISON_TAB_H_INCLUDED  */
