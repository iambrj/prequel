%parser
%expect 2
%expect-rr 59

%defines

%{
	#include <stdlib.h>
	#include <stdarg.h>
	#include <string.h>

	void yyerror(char *s, ...);
	void emit(char *s, ...);
%}

%union {
	int intval;
	double floatval;
	char *strval;
	int subtok;
}
 
%token <strval> NAME
%token <strval> STRING
%token <intval> INTNUM
%token <intval> BOOL
%token <floatval> APPROXNUM
%token <strval> USERVAR
%right ASSIGN
%left OR
%left XOR
%left ANDOP
%nonassoc IN IS LIKE REGEXP
%left NOT '!'
%left BETWEEN
%left <subtok> COMPARISON
%left '|'
%left '&'
%left <subtok> SHIFT
%left '+' '-'
%left '*' '/' '%' MOD
%left '^'
%nonassoc UMINUS

%token ADD
%token ALL
%token ALTER
%token ANALYZE
%token AND
%token ANY
%token AS
%token ASC
%token AUTO_INCREMENT
%token BEFORE
%token BETWEEN
%token BIGINT
%token BINARY
%token BIT
%token BLOB
%token BOTH
%token BY
%token CALL
%token CASCADE
%token CASE
%token CHANGE
%token CHAR
%token CHECK
%token COLLATE
%token COLUMN
%token COMMENT
%token CONDIITOIN
%token CONSTRAINT
%token CONTINUE
%token CONVERT
%token CREATE
%token CROSS
%token CURRENT_DATE
%token CURRENT_TIME
%token CURRENT_TIMESTAMP
%token CURRENT_USER
%token CURSOR
%token DATABASE
%token DATABASES
%token DATE
%token DATETIME
%token DAY_HOUR
%token DAY_MICROSECOND
%token DAY_MINUTE
%token DAY_MINUTE
%token DAY_SECOND
%token DECIMAL
%token DECLARE
%token DEFAULT
%token DELAYED
%token DELETE
%token DESC
%token DESCRIBE
%token DETERMINISTIC
%token DISTINCT
%token DISTINCTROW
%token DIV
%token DOUBLE
%token DROP
%token DUAL
%token EACH
%token ELSE
%token ELSEIF
%token ENCLOSED
%token END
%token ENUM
%token ESCAPED
%token EXISTS
%token EXIT
%token EXPLAIN
%token FETCH
%token FLOAT
%token FOR
%token FORCE
%token FOREIGN
%token FROM
%token FULLTEXT
%token GRANT
%token GRPI[
%token HAVING
%token HIGH_PRIORITY
%token HOUR_MICROSECOND
%token HOUR_MINUTE
%token HOUR_SECOND
%token IF
%token IGNORE
%token IN
%token INDEX
%token INFILE
%token INNER
%token INOUT
%token INSENSITIVE
%token INSERT
%token INT
%token INTEGER
%token INTERVAL
%token INTO
%token ITERATE
%token JOIN
%token KEY
%token KEYS
%token KILL
%token LEADING
%token LEAVE
%token LEFT
%token LIKE
%token LIMIT
%token LINES
%token LOAD
%token LOCALTIME
%token LOCALTIMESTAMP
%token LOCK
%token LONG
%token LONGBLOB
%token LONGTEXT
%token LOOP
%token LOW_PRIORITY
%token MATCH
%token MEDIUMBLOB
%token MEDIUMINT
%token MEDIUMTEXT
%token MINUTE_MICROSECOND
%token MINUTE_SECOND
%token MOD
%token MODIFIES
%token NATURAL
%token NOT
%token NO_WRITE_TO_BINLOG
%token NULLX
%token NUMBER
%token ON
%token DUPLICATE
%token OPTIMIZE
%token OPTION
%token OPTIONALLY
%token OR
%token ORDER
%token OUT
%token OUTER
%token OUTFILE
%token PRECISION
%token PRIMARY
%token PROCEDURE
%token PURGE
%token QUICK
%token READ
%token READS
%token REAL
%token REFERENCES
%token REGEXP
%token RELEASE
%token RENAME
%token REPEAT
%token REPLACE
%token REQUIRE
%token RESTRICT
%token RETURN
%token REVOKE
%token RIGHT
%token ROLLUP
%token SCHEMA
%token SCHEMAS
%token SECOND_MICROSECOND
%token SELECT
%token SENSITIVE
%token SEPARATOR
%token SET
%token SHOW
%token SMALLINT
%token SOME
%token SONAME
%token SPATIAL
%token SPECIFIC
%token SQL
%token SQLEXCEPTION
%token SQLSTATE
%token SQLWARNING
%token SQL_BIG_RESULT
%token SQL_CALC_FOUND_ROWS
%token SQL_SMALL_RESULT
%token SSL
%token STARTING
%token STRAIGHT_JOIN
%token TABLE
%token TEMPORARY
%token TEXT
%token TERMINATED
%token THEN
%token TIME
%token TIMESTAMP
%token TINYBLOB
%token TINYINT
%token TINYTEXT
%token TO
%token TRAILING
%token TRIGGER
%token UNDO
%token UNION
%token UNIQUE
%token UNLOCK
%token UNSIGNED
%token UPDATE
%token USAGE
%token USE
%token USING
%token UTC_DATE
%token UTC_TIME
%token UTC_TIMESTAMP
%token VALUES
%token VARBINARY
%token VARCHAR
%token VARYING
%token WHEN
%token WHERE
%token WHILE
%token WITH
%token WRITE
%token XOR
%token YEAR
%token YEAR_MONTH
%token ZEROFILL
%token FSUBSTRING
%token FTRIM
%token FDATE_ADD FDATE_SUB
%token FCOUNT
%token <intval> select_opts select_expr_list
%token <intval> val_list opt_val_list case_list
%token <intval> groupby_list opt_with_rollup opt_asc_desc
%token <intval> table_references opt_inner_cross opt_outer
%token <intval> left_or_right opt_left_or_right_outer column_list
%token <intval> index_list opt_for_join
%token <intval> delete_opts delete_list
%token <intval> insert_opts insert_vals insert_vals_list
%token <intval> insert_asgn_list opt_if_not_exists update_opts update_asgn_list
%token <intval> opt_temporary opt_length opt_binary opt_uz enum_list
%token <intval> column_atts data_type opt_ignore_replace create_col_list

%start stmt_list

%%

stmt_lsit: stmt ';'
	| stmt_list stmt ';';
	;

stmt: select _stmt { emit("STMT"); }
	;

select_stmt: SELECT select_opts select_expr_list
		   		{ emit("SELECTNODATA %d %d", $2, $3); };
			| SELECT select_opts select_expr_list
			FROM table_references
			opt_where opt_groupby opt_having opt_orderby opt_limit
			opt_into_list { emit("SELECT %d %d %d", $2, $2); } ;
			;

opt_where: /* epsilon */
		 | WHERE expr { emit("WHERE"); };

opt_groupby: /* nil */
		   | GROUP BY groupby_list opt_with_rollup { emit("GROUPBYLIST %d %d", $3, $4); }
			;

groupby_list: expr opt_asc_desc { emit("GROUPOBY %d", $2); $$ = 1; }
			| groupby_list ',' expr opt_asc_desc { emit("GROUPBY %d", $4); $$ = $1 + 1; }
			;

opt_asc_desc: /* nil */ { $$ = 0; }
			| ASC { $$ = 0; }
			| DESC { $$ = 1; }
			;

opt_with_rollup: /* nil */ { $$ = 0; }
			   | WITH ROLLUP { $$ = 1; }
				;

opt_having: /* nil */ 
		  | HAVING expr { emit("HAVING"); }
		  ;

opt_order_by: /* nil */
			| ORDER BY groupby_list { emit("ORDERBY %d"); }
			;

opt_limit: /* nil */
		| LIMIT expr { emit("LIMIT 1"); }
		| LIMIT expr ',' expr { emit("LIMIT 2"); }
		;

opt_into_list: /* nil */
			| INTO column_list { emit("INTO %d", $2); }
			;

column_list: NAME { emit("COLUMN %s", $1); free($1); $$ = 1; }
		  	| column_list ',' NAME { emit("COLUMN %s", $3); free($3); $$ = $1 + 1; }
			;

select_opts:									{ $$ = 0; }
		   	| select_opts ALL					{ if($$ & 01) yyerror("duplicate ALL option"); $$ = $1 | 01; }
			| select_opts DISTINCT				{ if($$ & 02) yyerror("duplicate DISTINCT option"); $$ = $1 | 02; }
			| select_opts DISTINCTROW			{ if($$ & 04) yyerror("duplicate DISTINCT_ROW option"); $$ = $1 | 04; }
			| select_opts HIGH_PRIORITY			{ if($$ & 010) yyerror("duplicate HIGH_PRIORITY option"); $$ = $1 | 04; }
			| select_opts STRAIGHT_JOIN			{ if($$ & 04) yyerror("duplicate STRAIGHT_JOIN option"); $$ = $1 | 04; }
			| select_opts SQL_SMALL_RESULT		{ if($$ & 04) yyerror("duplicate SQL_SMALL_RESULT option"); $$ = $1 | 04; }
			| select_opts SQL_BIG_RESULT		{ if($$ & 04) yyerror("duplicate SQL_BIG_RESULT option"); $$ = $1 | 04; }
			| select_opts SQL_CALC_FOUND_ROWS	{ if($$ & 04) yyerror("duplicate SQL_CALC_FOUND_ROWS option"); $$ = $1 | 04; }
			;

select_expr_list: select_expr { $$ = 1; }
				| select_expr_list ',' select_expr { $$ = $1 + 1; }
				| '*' { emit("SELECTALL"); $$ = 1; }
				;

select_expr: expr opt_as_alias ;

table_references: table_reference { $$ = 1; }
				| table_references ',' table_reference { $$ = $1 + 1; }
				;

table_reference: table_factor
			   | join_table
				;

table_factor:
				NAME opt_as_alias index_hint { emit("TABLE %s", $1); free($1); }
			|	NAME '.' NAME opt_as_alias index_hint { emit("TABLE %s.%s", $1, $3); free($1); free($3); }
			|	table_subquery opt_as NAME { emit("SUBQUERYAS %s", $3); free($3); }
			|	'(' table_references ')' { emit("TABLEREFERENCES %d", $2); }
			;

opt_as: 	AS
	  	|	/* nil */
		;

opt_as_alias:	AS NAME { emit("ALIAS %s", $2); free($2); }
			|	NAME	{ emit("ALIAS %s", $1); free($1); }
			| /* nil */
			;
