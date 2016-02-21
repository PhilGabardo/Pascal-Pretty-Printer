grammar indent;

r: program;

program :  programheader (SPACE)? declarations (SPACE)? compoundstatement 
		{
			// indent declarations
			System.out.println($programheader.text);
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "\t" + lines.get(i));
			}

			// print compound statements without indentation
			lines.addAll($compoundstatement.lines);
			for (int i = 0; i < lines.size(); i++) {
				System.out.println(lines.get(i));
			}
		};

programheader : 'program' (SPACE)? IDENT (SPACE)? ';';

declarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		:
		( constdeclaration { $lines.addAll($constdeclaration.lines);} ) ?
		( typedeclaration { $lines.addAll($typedeclaration.lines); } ) ?
		( vardeclaration {$lines.addAll($vardeclaration.lines); } ) ?
		proceduredeclarations { $lines.addAll($proceduredeclarations.lines); } ;

constdeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("const");} 
		: 'const' (SPACE)? (constassignment (SPACE)?{
			$lines.add("\t" + $constassignment.text);
		})*;

constassignment : IDENT (SPACE)? '=' (SPACE)? expression (SPACE)? ';';

typedeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("type");}
		: 'type' (SPACE)? (typeassignment (SPACE)? {
			ArrayList<String> lines = $typeassignment.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);
			})*;

typeassignment returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: IDENT (SPACE)? '=' (SPACE)? type (SPACE)? ';'{
			if ($type.lines.size() > 1){
				$lines.add($IDENT.text + " =");
				ArrayList<String> lines = $type.lines;
				for (int i = 0; i < lines.size(); i++) {
                                	lines.set(i, "\t" + lines.get(i));
                        	}
				$lines.addAll(lines);
			}
			else{
				$lines.add($IDENT.text + " = " + $type.lines.get(0));
			}
		};

vardeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("var");} 
		: 'var' (SPACE)? (varassignment (SPACE)?{
			$lines.add("\t" + $varassignment.text)
		;})*;

varassignment : identlist (SPACE)? ':' (SPACE)? type (SPACE)? ';';

proceduredeclarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: ((SPACE)? proceduredeclaration (SPACE)? ';' (SPACE)? {$lines.addAll($proceduredeclaration.lines);})*;

proceduredeclaration returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();} 
		: procedureheader (SPACE)? declarations (SPACE)? compoundstatement 
		{
                	$lines.add($procedureheader.text);
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
                        $lines.addAll(lines);
                        $lines.addAll($compoundstatement.lines);
		};

procedureheader : 'procedure' (SPACE)? IDENT (SPACE)? formalparameters (SPACE)? ';';

formalparameters : '(' (SPACE)? (fpsection (SPACE)?  (';' (SPACE)? fpsection (SPACE)?)*)? (SPACE)? ')';

fpsection : ('var')? (SPACE)? identlist (SPACE)? ':' (SPACE)? type;

type returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: IDENT { $lines.add($IDENT.text); } 
		| arraytype {
			ArrayList<String> lines = $arraytype.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);} 
		| recordtype{
			ArrayList<String> lines = $recordtype.lines;
                        for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);};

recordtype returns [ArrayList<String> lines]
	@init { $lines = new ArrayList<String>();} 
	: 'record' (SPACE)? fieldlist (SPACE)? 'end'
		{
			$lines.add("record");
			$lines.add("\t" + $fieldlist.text);
			$lines.add("end");
                }
	| 'record' (SPACE)? terminatedfieldlists (SPACE)? fieldlist (SPACE)? 'end'
		{
			$lines.add("record");
                        ArrayList<String> lines = $terminatedfieldlists.lines;
                        for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
                        $lines.addAll(lines);
			$lines.add("\t" + $fieldlist.text);
                        $lines.add("end");
		};

terminatedfieldlists returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (fieldlist (SPACE)? ';' (SPACE)? {$lines.add($fieldlist.text + ';');})*;

fieldlist : (identlist (SPACE)? ':' (SPACE)? type)?;

arraytype returns [ArrayList<String> lines]
	@init { $lines = new ArrayList<String>();}
	: arraydeclaration (SPACE)? type
	{
		if ($type.lines.size() > 1){
			$lines.add($arraydeclaration.text);
			ArrayList<String> lines = $type.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
                        $lines.addAll(lines);
		}
		else{
			$lines.add($arraydeclaration.text + $type.lines.get(0)); 
		}
	};

arraydeclaration : 'array' (SPACE)? '[' (SPACE)? expression (SPACE)? '..' (SPACE)? expression (SPACE)? ']' (SPACE)? 'of'; 


identlist : IDENT (SPACE)? (',' (SPACE)? IDENT (SPACE)?)*;

statement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: assignment{$lines.add($assignment.text);}
		| procedurecall{$lines.add($procedurecall.text);}
		| compoundstatement{$lines.addAll($compoundstatement.lines);}
		| ifstatement{$lines.addAll($ifstatement.lines);}
		| whilestatement{$lines.addAll($whilestatement.lines);};

whilestatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: whileheader (SPACE)? statement
		{
			$lines.add($whileheader.text);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);
                };

whileheader : 'while' (SPACE)?  expression (SPACE)? 'do';

ifstatement returns [ArrayList<String> lines] 
		@init { $lines = new ArrayList<String>();}
		: ifheader (SPACE)? statement {
			$lines.add($ifheader.text);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);
		}
		| ifheader (SPACE)? statement (SPACE)? elsestatement {
			$lines.add($ifheader.text);
			ArrayList<String> lines = $statement.lines;
                	for (int i = 0; i < lines.size(); i++) {
                        	lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.addAll($elsestatement.lines);
		}; 

ifheader : 'if' (SPACE)? expression (SPACE)? 'then';

elsestatement returns [ArrayList<String> lines]
		 @init { $lines = new ArrayList<String>();}
		: 'else' (SPACE)? statement
		{
			$lines.add("else");
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
                        $lines.addAll(lines);
		};



compoundstatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: 'begin' (SPACE)? statement (SPACE)? 'end'
		{
			$lines.add("begin");
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
                        $lines.addAll(lines);
                        $lines.add("end");
                }
		| 'begin' (SPACE)? terminatedstatements (SPACE)? statement (SPACE)? 'end'
		{
			$lines.add("begin");
			ArrayList<String> lines = $terminatedstatements.lines;
			lines.addAll($statement.lines);
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "\t" + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.add("end");
		};

terminatedstatements returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (statement (SPACE)? ';' (SPACE)? {
			$lines.addAll($statement.lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		})*;

procedurecall : IDENT (SPACE)? selector (SPACE)? (actualparameters)?;

actualparameters : '(' (SPACE)? (expression (SPACE)? (',' (SPACE)? expression (SPACE)?)*)? (SPACE)? ')';

assignment : IDENT (SPACE)? selector (SPACE)? ':=' (SPACE)? expression;

expression : simpleexpression (SPACE)? (('=' | '<>' | '<' | '<=' | '>' | '>=') (SPACE)? simpleexpression (SPACE)?)*;

simpleexpression : ('+' | '-')? (SPACE)? term (SPACE)? (('+' | '-' | 'or') (SPACE)? term (SPACE)?)*;

term : factor (SPACE)? (('*' | 'div' | 'mod' | 'and') (SPACE)? factor (SPACE)?)*;

factor : IDENT (SPACE)? selector | INTEGER | '(' (SPACE)? expression (SPACE)? ')' | 'not' (SPACE)? factor;

selector : ('.' (SPACE)? IDENT | '[' (SPACE)? expression (SPACE)? ']' (SPACE)?)*;

INTEGER : DIGIT (DIGIT)*;

IDENT : LETTER (LETTER | DIGIT)*;

DIGIT : '0'..'9';

LETTER : 'a' .. 'z' | 'A' .. 'Z';

SPACE : [ ]+;

WS : [\t\r\n]+ -> skip;
