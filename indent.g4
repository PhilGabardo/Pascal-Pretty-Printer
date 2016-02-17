grammar indent;

r: program;

program : 'program' IDENT ';' declarations compoundstatement
		{
			// indent declarations
			System.out.println("program " + $IDENT.text + ";");
			ArrayList<String> lines = $declarations.lines;
			lines.addAll($compoundstatement.lines);
			for (int i = 0; i < lines.size(); i++) {
				System.out.println(lines.get(i));
			}
		};

declarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		:
		constdeclaration (typedeclaration)? (vardeclaration)? proceduredeclarations { $lines.addAll($constdeclaration.lines); }
		| typedeclaration { $lines.add($typedeclaration.text); }
		| vardeclaration {$lines.add($vardeclaration.text); }
		| proceduredeclarations { $lines.addAll($proceduredeclarations.lines); };

constdeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();} 
		: 'const' (constassignment {$lines.add($constassignment.text);})*;

constassignment : IDENT '=' expression ';';

typedeclaration : 'type' (typeassignment)*;

typeassignment : IDENT '=' type ';';

vardeclaration : 'var' (varassignment)*;

varassignment : identlist ':' type ';';

proceduredeclarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: (proceduredeclaration ';' {$lines.addAll($proceduredeclaration.lines);})*;

proceduredeclaration returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();} 
		: 'procedure' IDENT ';' declarations compoundstatement 
		{
                	$lines.add("procedure");
                        $lines.add($IDENT.text);
                        $lines.add(";");
                        $lines.addAll($declarations.lines);
                        $lines.addAll($compoundstatement.lines);
		}
		| 'procedure' IDENT formalparameters ';' declarations compoundstatement
		{
			$lines.add("procedure");
			$lines.add($IDENT.text);
			$lines.add($formalparameters.text);
			$lines.add(";");
			$lines.addAll($declarations.lines);
			$lines.addAll($compoundstatement.lines);
		};

formalparameters : '(' (fpsection (';' fpsection)*)? ')';

fpsection : ('var')? identlist ':' type;

type : IDENT | arraytype | recordtype;

recordtype returns [ArrayList<String> lines]
	@init { $lines = new ArrayList<String>();} 
	: 'record' fieldlists 'end'
		{
			$lines.add("record");
			$lines.addAll($fieldlists.lines);
			$lines.add("end");
                };

fieldlists returns [ArrayList<String> lines]
        @init { $lines = new ArrayList<String>();}
        : (';' fieldlist {$lines.add($fieldlist.text);})* ;

fieldlist : (identlist ':' type)?;

arraytype : 'array' '[' expression '..' expression ']' 'of' type;

identlist : IDENT (',' IDENT)*;

statement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: assignment{$lines.add($assignment.text);}
		| procedurecall{$lines.add($procedurecall.text);}
		| compoundstatement{$lines.addAll($compoundstatement.lines);}
		| ifstatement{$lines.addAll($ifstatement.lines);}
		| whilestatement{$lines.addAll($whilestatement.lines);};

whilestatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: 'while' expression 'do' statement
		{
			$lines.add("while");
			$lines.add($expression.text);
			$lines.add("do");
			$lines.addAll($statement.lines);
                };

ifstatement returns [ArrayList<String> lines] 
		@init { $lines = new ArrayList<String>();}
		: 'if' expression 'then' statement {
			$lines.add("if");
			$lines.add($expression.text);
			$lines.add("then");
			$lines.addAll($statement.lines);
		}
		| 'if' expression 'then' statement elsestatement {
			$lines.add("if");
               		$lines.add($expression.text);
                	$lines.add("then");
                	$lines.addAll($statement.lines);
			$lines.add("else");
			$lines.addAll($elsestatement.lines);
		}; 

elsestatement returns [ArrayList<String> lines]
		 @init { $lines = new ArrayList<String>();}
		: 'else' statement
		{
			$lines.add("else");
			$lines.addAll($statement.lines);
		};



compoundstatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: 'begin' statement statements 'end'
		{
			$lines.add("begin");
			$lines.addAll($statement.lines);
			$lines.addAll($statements.lines);
			$lines.add("end");	
                };

statements returns [ArrayList<String> lines] 
	@init { $lines = new ArrayList<String>();}  
	: (';' statement {$lines.addAll($statement.lines);})* ;


procedurecall : IDENT selector (actualparameters)?;

actualparameters : '(' (expression (',' expression)*)? ')';

assignment : IDENT selector ':=' expression;

expression : simpleexpression (('=' | '<>' | '<' | '<=' | '>' | '>=') simpleexpression)*;

simpleexpression : ('+' | '-')? term (('+' | '-' | 'or') term)*;

term : factor (('*' | 'div' | 'mod' | 'and') factor)*;

factor : IDENT selector | INTEGER | '(' expression ')' | 'not' factor;

selector : ('.' IDENT | '[' expression ']')*;

INTEGER : DIGIT (DIGIT)*;

IDENT : LETTER (LETTER | DIGIT)*;

DIGIT : '0'..'9';

LETTER : 'a' .. 'z' | 'A' .. 'Z';

WS : [ \t\r\n]+ -> skip;

