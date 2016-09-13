%token CONTRACT
%token <string> IDENT
%token ADDRESS
%token UINT
%token BOOL
%token LPAR
%token RPAR
%token COMMA
%token LSQBR
%token RSQBR
%token LBRACE
%token RBRACE
%token CASE
%token DEFAULT
%token IF
%token RETURN
%token FALSE
%token TRUE
%token THEN
%token SEMICOLON
%token EQUALITY
%token NEQ
%token LT
%token GT
%token SINGLE_EQ
%token NEW
%token ALONG
%token WITH
%token REENTRANCE
%token ABORT
%token HEIR
%token SELFDESTRUCT
%token EOF


%start <Contract.contract list> file
%%

file:
  | cs = contracts; EOF; { cs }
  ;

contracts:
  | cs = rev_contracts { List.rev cs }
  ;

rev_contracts:
  | (* empty *) { [] }
  | cs = rev_contracts;
    CONTRACT;
    IDENT; LPAR; RPAR;
    LBRACE;
    css = cases;
    RBRACE;
    { { Contract.contract_cases = css; } :: cs }
  ;

cases:
  | css = rev_cases { List.rev css }
  ;

rev_cases:
  | (* empty *) { [] }
  | css = rev_cases;
    ch  = case_header;
    cb  = block;
    {
      { Contract.case_header = ch
      ; Contract.case_body = cb
      }
      :: css }
  ;

block:
  | LBRACE;
    scs = sentences;
    RBRACE
    { scs }
  ;

case_header:
  | DEFAULT { DefaultCaseHeader }
  | CASE; LPAR;
    typ;
    IDENT; (* function name *)
    LPAR;
    args = argument_list;
    RPAR;
    RPAR { UsualCaseHeader }
  ;

argument_list:
  | args = rev_argument_list { List.rev args }

rev_argument_list:
  | (* empty *) { [] }
  | args = non_empty_rev_argument_list;
    { args }
  ;

non_empty_rev_argument_list:
  | a = arg { [ a ] }
  | args = non_empty_rev_argument_list;
    COMMA;
    a = arg
    { a :: args }
  ;

arg:
  | t = typ;
    i = IDENT
    { { Contract.arg_typ = t
      ; Contract.arg_ident = i
      }
    }

typ:
  | UINT { Contract.UintType }

sentences:
  | scs = rev_sentences { List.rev scs }
  ;

rev_sentences:
  | (* empty *) { [] }
  | scs = rev_sentences;
    ABORT;
    SEMICOLON;
    { Contract.AbortSentence :: scs }
  ;
