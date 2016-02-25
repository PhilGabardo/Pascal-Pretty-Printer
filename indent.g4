grammar indent;

r: program;

program :  programheader  declarations  compoundstatement '.' 
		{
			// indent declarations
			System.out.println($programheader.line);
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "  " + lines.get(i));
			}

			// print compound statements without indentation
			lines.addAll($compoundstatement.lines);
			lines.set(lines.size() - 1, lines.get(lines.size()-1) + ".");
			for (int i = 0; i < lines.size(); i++) {
				System.out.println(lines.get(i));
			}
		};

programheader returns [String line]: 'program'  IDENT  ';' {$line = "program " + $IDENT.text + ";";};

declarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		:
		( constdeclaration { $lines.addAll($constdeclaration.lines);} ) ?
		( typedeclaration { $lines.addAll($typedeclaration.lines); } ) ?
		( vardeclaration {$lines.addAll($vardeclaration.lines); } ) ?
		proceduredeclarations { $lines.addAll($proceduredeclarations.lines); } ;

constdeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("const");} 
		: 'const'  (constassignment {
			$lines.add("  " + $constassignment.line);
		})*;

constassignment returns [String line] : IDENT  '='  expression  ';' {$line = $IDENT.text + " = " + $expression.line + ";"; };

typedeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("type");}
		: 'type'  (typeassignment  {
			ArrayList<String> lines = $typeassignment.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			})*;

typeassignment returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: identassignment {$lines.add($identassignment.line);}
		| IDENT  '='  arraytype  ';'{
			$lines.add($IDENT.text + " = ");
                        ArrayList<String> lines = $arraytype.lines;
                        for (int i = 0; i < lines.size(); i++){
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		}
		| IDENT '=' recordtype ';'{
			$lines.add($IDENT.text + " = ");
			ArrayList<String> lines = $recordtype.lines;
			for (int i = 0; i < lines.size(); i++){
				lines.set(i, "  " + lines.get(i));
			}
			$lines.addAll(lines);	
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		};

identassignment returns [String line] 
		@init { $line = "";}
		:  (IDENT {$line += $IDENT.text;} ) ('=' {$line += " = ";}) (IDENT {$line += $IDENT.text;}) (';' {$line += ";";});


vardeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("var");} 
		: 'var'  (varassignment {
			ArrayList<String> lines = $varassignment.lines;
			for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
		;})*;

varassignment returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: identlist ':'  IDENT  ';' {$lines.add($identlist.line + ": " + $IDENT.text + ";");}
		| identlist ':' arraytype ';'{
			$lines.add($identlist.line + ": ");
			ArrayList<String> lines = $arraytype.lines;
			for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		}
		| identlist ':' recordtype ';'{
			$lines.add($identlist.line + ": ");
                        ArrayList<String> lines = $recordtype.lines;
                        for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		};

proceduredeclarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: ( proceduredeclaration  ';'  {
			$lines.addAll($proceduredeclaration.lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		})*;

proceduredeclaration returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();} 
		: procedureheader  declarations  compoundstatement 
		{
                	$lines.add($procedureheader.line);
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);
                        $lines.addAll($compoundstatement.lines);
		};

procedureheader returns [String line]: 'procedure'  IDENT  formalparameters  ';' {$line = "procedure " + $IDENT.text + $formalparameters.line + ";";};

formalparameters returns [String line]: ('(' {$line = "(";} ) ( (fpsection {$line += $fpsection.line;})   (';'  fpsection {$line += "; " + $fpsection.line;} )*)?  (')' {$line += ")";});

fpsection returns [String line]
		@init { $line = "";}
		: ('var' {$line = "var ";})?  (identlist {$line += $identlist.line;})  (':' {$line +=  ": ";})  (type {$line += $type.text;}) ; 

type : arraytype | recordtype | IDENT;

recordtype returns [ArrayList<String> lines]
	@init { $lines = new ArrayList<String>();} 
	: 'record'  fieldlist  'end'
		{
			$lines.add("record");
			ArrayList<String> lines = $fieldlist.lines;
			for (int i = 0; i < lines.size(); i++) {
                    		lines.set(i, "  " + lines.get(i));
                	}
                	$lines.addAll(lines);
			$lines.add("end");
                }
	| 'record'  terminatedfieldlists  fieldlist  'end'
		{
			$lines.add("record");
                        ArrayList<String> lines = $terminatedfieldlists.lines;
                        lines.addAll($fieldlist.lines);
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
                        $lines.add("end");
		};

terminatedfieldlists returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (fieldlist  ';'  {$lines.addAll($fieldlist.lines); $lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");})*;

fieldlist returns [ArrayList<String> lines]
	@init {$lines = new ArrayList<String>();} 
	: (identlist  ':'  IDENT {$lines.add($identlist.line + ": " + $IDENT.text);})?
	| (identlist ':' arraytype {
		$lines.add($identlist.line + ": ");
		ArrayList<String> lines = $arraytype.lines;
		for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	})?
	| (identlist ':' recordtype {
		$lines.add($identlist.line + ": ");
                ArrayList<String> lines = $recordtype.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	})?;

arraytype returns [ArrayList<String> lines]
	: arraydeclaration  IDENT
	{
		$lines = new ArrayList<String>();
		$lines.add($arraydeclaration.line + " " +$IDENT.text);
	}
	| arraydeclaration arraytype
	{
		$lines = new ArrayList<String>();
		System.out.print("HERE\n");	
		$lines.add($arraydeclaration.line);
		ArrayList<String> lines = $arraytype.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	}
	| arraydeclaration recordtype
	{
		$lines = new ArrayList<String>();
		$lines.add($arraydeclaration.line);
                ArrayList<String> lines = $recordtype.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	};

arraydeclaration returns [String line]
	: ('array'  '['  expression { $line = "array [" + $expression.line;}) ( '..'  expression  ']'  'of' {$line += " .. " + $expression.line + "] of";}); 


identlist returns [String line]: (IDENT {$line = $IDENT.text;})   (','  IDENT  {$line += ", " + $IDENT.text;})*;

statement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: assignment{$lines.add($assignment.line);}
		| procedurecall{$lines.add($procedurecall.line);}
		| compoundstatement{$lines.addAll($compoundstatement.lines);}
		| ifstatement{$lines.addAll($ifstatement.lines);}
		| whilestatement{$lines.addAll($whilestatement.lines);};

whilestatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: whileheader  statement
		{
			$lines.add($whileheader.line);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
                };

whileheader returns [String line]: 'while'   expression  'do' {$line = "while " + $expression.line + " do";};

ifstatement returns [ArrayList<String> lines] 
		@init { $lines = new ArrayList<String>();}
		: ifheader  statement {
			$lines.add($ifheader.line);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
		}
		| ifheader  statement  elsestatement {
			$lines.add($ifheader.line);
			ArrayList<String> lines = $statement.lines;
                	for (int i = 0; i < lines.size(); i++) {
                        	lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.addAll($elsestatement.lines);
		}; 

ifheader returns [String line]: 'if'  expression  'then' {$line = "if " + $expression.line + " then";};

elsestatement returns [ArrayList<String> lines]
		 @init { $lines = new ArrayList<String>();}
		: 'else'  statement
		{
			$lines.add("else");
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);
		};



compoundstatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: 'begin'  statement  'end'
		{
			$lines.add("begin");
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);
                        $lines.add("end");
                }
		| 'begin'  terminatedstatements  statement  'end'
		{
			$lines.add("begin");
			ArrayList<String> lines = $terminatedstatements.lines;
			lines.addAll($statement.lines);
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.add("end");
		};

terminatedstatements returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (statement  ';'  {
			$lines.addAll($statement.lines);
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		})*;

procedurecall returns [String line]: (IDENT  selector {$line = $IDENT.text + $selector.text;})  (actualparameters {$line += $actualparameters.line;})?;

actualparameters returns [String line]: '('   (expression { $line = "(" + $expression.line; } (','  expression {$line += ", " + $expression.line;})*)?  (')' {$line += ")";});

assignment returns [String line] : IDENT  selector  ':='  expression {$line = $IDENT.text + $selector.text + " := " + $expression.line;};

expression returns [String line]: (simpleexpression {$line = $simpleexpression.line;}) (binbooleanoperator  simpleexpression {$line += " " + $binbooleanoperator.text + " " + $simpleexpression.line;})*;

binbooleanoperator : '=' | '<>' | '<' | '<=' | '>' | '>=';

simpleexpression returns [String line]
	@init {$line = "";}
	: (unarithoperator { $line = $unarithoperator.text;})?  (term {$line += $term.line;} )  (binarithoperator  term {$line += " " + $binarithoperator.text + " " + $term.line;} )*;

term returns [String line]: (factor {$line = $factor.line;})  ((factoroperator)  factor {$line += " " + $factoroperator.text + " " + $factor.line;} )*;

unarithoperator : '+' | '-';

binarithoperator : '+' | '-' | 'or';

factoroperator : '*' | 'div' | 'mod' | 'and';

factor returns [String line]: 
	IDENT  selector {$line = $IDENT.text + $selector.text;}
	| INTEGER {$line = $INTEGER.text;}
	| '('  expression  ')' {$line = "( " + $expression.line + " )";}
	| 'not'  factor {$line = "not " + $factor.line;};

selector returns [String line]
	@init {$line = "";}
	:('.'  IDENT {$line += "." + $IDENT.text;} | '['  expression  ']' {$line += "[" + $expression.line + "]";} )*;

INTEGER : DIGIT (DIGIT)*;

IDENT : LETTER (LETTER | DIGIT)*;

DIGIT : '0'..'9';

LETTER : 'a' .. 'z' | 'A' .. 'Z';

WS : [ \t\r\n]+ -> skip;
