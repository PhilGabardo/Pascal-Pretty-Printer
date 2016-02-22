# Pascal-Pretty-Printer (Credit to Emil Sekerinski)

This is an antlr program that "pretty prints" or "beautifies" Pascal0 source code. Consider the following grammar for Pascal0, written in Wirth-style EBNF:
```
ident = letter (letter | digit).
integer = digit {digit}.
selector = {"." ident | "[" expression "]"}.
factor = ident selector | integer | "(" expression ")" | "not" factor.
term = factor {("*" | "div" | "mod" | "and") factor}.
SimpleExpression = ["+" | "-"] term {("+" | "-" | "or") term}.
expression = SimpleExpression{("=" | "<>" | "<" | "<=" | ">" | ">=") SimpleExpression}.
assignment = ident selector ":=" expression.ActualParameters = "(" [expression {"," expression}] ")".
ProcedureCall = ident selector [ActualParameters].
CompoundStatement = "begin" statement {";" statement} "end".
IfStatement = "if" expression "then" Statement ["else" Statement].
WhileStatement = "while" expression "do" Statement.
Statement = [assignment | ProcedureCall | CompoundStatement |IfStatement | WhileStatement].
IdentList = ident {"," ident}.
ArrayType = "array" "[" expression ".." expression "]" "of" type.
FieldList = [IdentList ":" type].RecordType = "record" FieldList {";" FieldList} "end".
type = ident | ArrayType | RecordType.
FPSection = ["var"] IdentList ":" type.FormalParameters = "(" [FPSection {";" FPSection}] ")".
ProcedureDeclaration = "procedure" ident [FormalParameters] ";"declarations CompoundStatement.
declarations = ["const" {ident "=" expression ";"}]["type" {ident "=" type ";"}]["var" {IdentList ":" type ";"}]{ProcedureDeclaration ";"}.
program = "program" ident ";"declarations CompoundStatement.
```

The beautifier reads a Pascal0 program from standard input and writes the same program to standard output, but with systematic indentation of the control structures and declarations. That is, bracketed constructs like begin-end and if-then-else should be indented in a readable way:
* Expressions are assumed to fit on one line and are output without reformatting.
* Statements, declarations, and types may go over several lines and need to be broken and indented. All statements start a new line. 
* Assignments and procedure calls are assumed to fit on one line.  
* Each constant, type, variable declaration starts a new line.
* Type alias declarations are assumed to fit on one line, array and record declarations start a new line; each new field declaration starts a new line.
* The program header is not indented, the main program declarations are indented once,the main program body is not indented:program headers are not indented, local declarations are indented once, the procedure body is not indented.
