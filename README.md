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

The beautifier reads a Pascal0 program from standard input and writes the same program to standard output, but with systematic indentation of the control structures and declarations. That is, bracketed constructs like begin-end and if-then-else are indented in a readable way, and whitespace is inserted between text to make the program readable.


## Example

Consider the following Pascal0 code that is poorly formatted:
```
program testindent;
const c = 44; type t = integer; var s,i,j,a,b,d: t;
r : record x, y: integer; b,c :boolean; a : array [1.. 100] of t end;
procedure p(var g: t); type
  q = array [20 .. 30] of array [-12 .. 67] of t;
  begin i := 3; if a = a then i := j + 1 else if
    b = a then j := 99
 end;

begin while d < 9 do p(i); if a = 99 then begin j := 100 end;
begin i := 100 end end.
```

This program will generate the following code given the poorly formatted code above:

```
program testindent;
  const
    c = 44;
  type
    t = integer;
  var
    s, i, j, a, b, d: t;
    r:
      record
        x, y: integer;
        b, c: boolean;
        a:
          array [1 .. 100] of t
      end;
  procedure p(var g: t);
    type
      q =
        array [20 .. 30] of
          array [-12 .. 67] of t;
  begin
    i := 3;
    if a = a then
      i := j + 1
    else
      if b = a then
        j := 99
  end;
begin
  while d < 9 do
    p(i);
  if a = 99 then
    begin
      j := 100
    end;
  begin
    i := 100
  end
end.
```

## Building and running
You must have ANTLR (version 4) installed to run this program (see https://github.com/antlr/antlr4/blob/master/doc/getting-started.md). To build the program run:

```
antlr4 indent.g4
javac *.java
grun indent r <YOUR_PASCAL0_CODE>
```
