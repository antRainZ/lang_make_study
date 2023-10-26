grammar THFE;

file:  (functionDecl | varDecl | stat )+ ;

varDecl
    :   type ID ('=' expr)? ';'
    |   type ID '[' expr ']' ';'
    ;

functionDecl
    :   type ID '(' formalParameters? ')' block
    ;
formalParameters
    :   formalParameter (',' formalParameter)*
    ;
formalParameter
    :   type ID
    ;

block:  '{' stat* '}' ;   // possibly empty statement block
stat:   block
    |   varDecl
    |   'if' '('  expr ')' block ('else' block)?
    |   'return' expr? ';'
    |   'for' ID '=' expr 'to' expr 'do' block
    |   expr '=' expr ';' // assignment
    |   expr ';'          // func call
    ;

expr
    : selfExpr
    | ID '(' exprList? ')'    // func call like f(), f(x), f(1,2)
    | ID '[' expr ']'         // array index like a[i], a[i][j]
    |   '-' expr                // unary minus
    |   '!' expr                // boolean not
    |    expr '^' expr
    |   expr '*' expr
    |   expr ('+'|'-') expr
    |   expr '==' expr          // equality comparison (lowest priority op)
    |   ID                      // variable reference
    |   INT
    |   '(' expr ')'
    ;

selfExpr
    : 'Exterprod' '(' expr ',' expr ')' # exterprod
    | 'CMUX' '(' expr ',' expr ',' expr ')' # cmux
    | 'HomNAND' '(' expr ')' # homNAND
    | 'HomAND' '(' expr ',' expr ')' # homAND
    | 'HomOR' '(' expr ',' expr ')' # homOR
    | 'HomXOR' '(' expr ',' expr ')' # homXOR
    | 'CirBootstrap' '(' expr ')' # cirBootstrap
    | 'Add' '(' expr ',' expr ')' # add
    | 'Subtraction' '(' expr ',' expr ')' # subtraction
    | 'ModularAdd' '(' expr ',' expr ')' # modularAdd
    | 'ModularSub' '(' expr ',' expr ')' # modularSub
    ;

exprList : expr (',' expr)* ;   // arg list

type
    : tlwe  # tlweNode
    | trlwe # trlweNode
    | trgsw # trgswNode
    | 'void' # void
    | 'int' # int
    ;

tlwe: 'tlwe' '<' expr '>';
trlwe: 'trlwe' '<' expr '>';
trgsw: 'trgsw' '<' expr '>';

ID : LETTER (LETTER | [0-9])* ;

fragment
LETTER : [a-zA-Z] ;


INT :   [0-9]+ ;

WS  :   [ \t\n\r]+ -> skip ;

SL_COMMENT
    :   '//' .*? '\n' -> skip
    ;