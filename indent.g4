grammar indent;

r: program;

program :  programHeader  declarations  compoundStatement '.' 
		{
			System.out.println($programHeader.line);
			
			// declarations need to be indented
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "  " + lines.get(i));
			}
			lines.addAll($compoundStatement.lines);
			
			// terminate program with period
			lines.set(lines.size() - 1, lines.get(lines.size()-1) + ".");
			
			// print program
			for (int i = 0; i < lines.size(); i++) {
				System.out.println(lines.get(i));
			}
		};

programHeader returns [String line]: 'program'  IDENT  ';' {$line = "program " + $IDENT.text + ";";};

declarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		:
		( constDeclaration { $lines.addAll($constDeclaration.lines);} ) ?
		( typeDeclaration { $lines.addAll($typeDeclaration.lines); } ) ?
		( varDeclaration {$lines.addAll($varDeclaration.lines); } ) ?
		procedureDeclarations { $lines.addAll($procedureDeclarations.lines); } ;

constDeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("const");} 
		: 'const'  (constAssignment {
			$lines.add("  " + $constAssignment.line);
		})*;

constAssignment returns [String line] : IDENT  '='  expression  ';' {$line = $IDENT.text + " = " + $expression.line + ";"; };

typeDeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("type");}
		: 'type'  (typeAssignment  {
			ArrayList<String> lines = $typeAssignment.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			})*;

typeAssignment returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: identAssignment {$lines.add($identAssignment.line);}
		| IDENT  '='  arrayType  ';'{
			$lines.add($IDENT.text + " = ");
                        ArrayList<String> lines = $arrayType.lines;
                        for (int i = 0; i < lines.size(); i++){
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			
			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		}
		| IDENT '=' recordType ';'{
			$lines.add($IDENT.text + " = ");
			ArrayList<String> lines = $recordType.lines;
			for (int i = 0; i < lines.size(); i++){
				lines.set(i, "  " + lines.get(i));
			}
			$lines.addAll(lines);	
	
			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		};

identAssignment returns [String line] 
		@init { $line = "";}
		:  (IDENT {$line += $IDENT.text;} ) ('=' {$line += " = ";}) (IDENT {$line += $IDENT.text;}) (';' {$line += ";";});


varDeclaration returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>(); $lines.add("var");} 
		: 'var'  (varAssignment {
			ArrayList<String> lines = $varAssignment.lines;
			for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
		;})*;

varAssignment returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: identList ':'  IDENT  ';' {$lines.add($identList.line + ": " + $IDENT.text + ";");}
		| identList ':' arrayType ';'{
			$lines.add($identList.line + ": ");
			ArrayList<String> lines = $arrayType.lines;
			for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
		
			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		}
		| identList ':' recordType ';'{
			$lines.add($identList.line + ": ");
                        ArrayList<String> lines = $recordType.lines;
                        for (int i = 0; i < lines.size(); i++) {
                              lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);

			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		};

procedureDeclarations returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
		: ( procedureDeclaration  ';'  {
			$lines.addAll($procedureDeclaration.lines);

			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		})*;

procedureDeclaration returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();} 
		: procedureHeader  declarations  compoundStatement 
		{
                	$lines.add($procedureHeader.line);
			ArrayList<String> lines = $declarations.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
                        $lines.addAll(lines);
                        $lines.addAll($compoundStatement.lines);
		};

procedureHeader returns [String line]: 'procedure'  IDENT  formalParameters  ';' {$line = "procedure " + $IDENT.text + $formalParameters.line + ";";};

formalParameters returns [String line]: ('(' {$line = "(";} ) ( (fpSection {$line += $fpSection.line;})   (';'  fpSection {$line += "; " + $fpSection.line;} )*)?  (')' {$line += ")";});

fpSection returns [String line]
		@init { $line = "";}
		: ('var' {$line = "var ";})?  (identList {$line += $identList.line;})  (':' {$line +=  ": ";})  (type {$line += $type.text;}) ; 

type : arrayType | recordType | IDENT;

recordType returns [ArrayList<String> lines]
	@init { $lines = new ArrayList<String>();} 
	: 'record'  fieldList  'end'
		{
			$lines.add("record");
			ArrayList<String> lines = $fieldList.lines;
			for (int i = 0; i < lines.size(); i++) {
                    		lines.set(i, "  " + lines.get(i));
                	}
                	$lines.addAll(lines);
			$lines.add("end");
                }
	| 'record'  terminatedFieldLists  fieldList  'end'
		{
			$lines.add("record");
                        ArrayList<String> lines = $terminatedFieldLists.lines;
                        lines.addAll($fieldList.lines);
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
                        $lines.add("end");
		};

terminatedFieldLists returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (fieldList  ';'  {$lines.addAll($fieldList.lines); $lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");})*;

fieldList returns [ArrayList<String> lines]
	@init {$lines = new ArrayList<String>();} 
	: (identList  ':'  IDENT {$lines.add($identList.line + ": " + $IDENT.text);})?
	| (identList ':' arrayType {
		$lines.add($identList.line + ": ");
		ArrayList<String> lines = $arrayType.lines;
		for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	})?
	| (identList ':' recordType {
		$lines.add($identList.line + ": ");
                ArrayList<String> lines = $recordType.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
	})?;

// I defined specific rules for array types to avoid defining the rule recursively.

arrayType returns [ArrayList<String> lines]
	@init{$lines = new ArrayList<String>();}
	: arrayTypeOfIdent 
	{
		ArrayList<String> lines = $arrayTypeOfIdent.lines;
                $lines.addAll(lines);
	}
	| arrayTypeOfArrayType
	{
		ArrayList<String> lines = $arrayTypeOfArrayType.lines;
                $lines.addAll(lines);
	}
	| arrayTypeOfRecordType
	{
		ArrayList<String> lines = $arrayTypeOfRecordType.lines;
                $lines.addAll(lines);
	};

arrayTypeOfIdent returns [ArrayList<String> lines]
	: arrayDeclaration  IDENT
        {
                $lines = new ArrayList<String>();
                $lines.add($arrayDeclaration.line + " " +$IDENT.text);
        };

arrayTypeOfArrayType returns [ArrayList<String> lines]
	: arrayDeclaration arrayType
	{
                $lines = new ArrayList<String>();
                $lines.add($arrayDeclaration.line);
                ArrayList<String> lines = $arrayType.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
        };

arrayTypeOfRecordType returns [ArrayList<String> lines]
	: arrayDeclaration recordType
        {
                $lines = new ArrayList<String>();
                $lines.add($arrayDeclaration.line);
                ArrayList<String> lines = $recordType.lines;
                for (int i = 0; i < lines.size(); i++) {
                    lines.set(i, "  " + lines.get(i));
                }
                $lines.addAll(lines);
        };

arrayDeclaration returns [String line]
	: ('array'  '['  expression { $line = "array [" + $expression.line;}) ( '..'  expression  ']'  'of' {$line += " .. " + $expression.line + "] of";}); 

identList returns [String line]: (IDENT {$line = $IDENT.text;})   (','  IDENT  {$line += ", " + $IDENT.text;})*;

statement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: assignment{$lines.add($assignment.line);}
		| procedureCall{$lines.add($procedureCall.line);}
		| compoundStatement{$lines.addAll($compoundStatement.lines);}
		| ifStatement{$lines.addAll($ifStatement.lines);}
		| whileStatement{$lines.addAll($whileStatement.lines);};

whileStatement returns [ArrayList<String> lines]
		@init { $lines = new ArrayList<String>();}
		: whileHeader  statement
		{
			$lines.add($whileHeader.line);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
				lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
                };

whileHeader returns [String line]: 'while'   expression  'do' {$line = "while " + $expression.line + " do";};

ifStatement returns [ArrayList<String> lines] 
		@init { $lines = new ArrayList<String>();}
		: ifHeader  statement {
			$lines.add($ifHeader.line);
			ArrayList<String> lines = $statement.lines;
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
		}
		| ifHeader  statement  elseStatement {
			$lines.add($ifHeader.line);
			ArrayList<String> lines = $statement.lines;
                	for (int i = 0; i < lines.size(); i++) {
                        	lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.addAll($elseStatement.lines);
		}; 

ifHeader returns [String line]: 'if'  expression  'then' {$line = "if " + $expression.line + " then";};

elseStatement returns [ArrayList<String> lines]
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



compoundStatement returns [ArrayList<String> lines]
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
		| 'begin'  terminatedStatements  statement  'end'
		{
			$lines.add("begin");
			ArrayList<String> lines = $terminatedStatements.lines;
			lines.addAll($statement.lines);
			for (int i = 0; i < lines.size(); i++) {
                                lines.set(i, "  " + lines.get(i));
                        }
			$lines.addAll(lines);
			$lines.add("end");
		};

terminatedStatements returns [ArrayList<String> lines]
                @init { $lines = new ArrayList<String>();}
                : (statement  ';'  {
			$lines.addAll($statement.lines);
			
			// terminate assignment with semicolon
			$lines.set($lines.size() - 1, $lines.get($lines.size() - 1) + ";");
		})*;

procedureCall returns [String line]: (IDENT  selector {$line = $IDENT.text + $selector.text;})  (actualParameters {$line += $actualParameters.line;})?;

actualParameters returns [String line]: '('   (expression { $line = "(" + $expression.line; } (','  expression {$line += ", " + $expression.line;})*)?  (')' {$line += ")";});

assignment returns [String line] : IDENT  selector  ':='  expression {$line = $IDENT.text + $selector.text + " := " + $expression.line;};

expression returns [String line]: (simpleExpression {$line = $simpleExpression.line;}) (binBooleanOperator  simpleExpression {$line += " " + $binBooleanOperator.text + " " + $simpleExpression.line;})*;

binBooleanOperator : '=' | '<>' | '<' | '<=' | '>' | '>=';

simpleExpression returns [String line]
	@init {$line = "";}
	: (unArithOperator { $line = $unArithOperator.text;})?  (term {$line += $term.line;} )  (binArithOperator  term {$line += " " + $binArithOperator.text + " " + $term.line;} )*;

term returns [String line]: (factor {$line = $factor.line;})  ((factorOperator)  factor {$line += " " + $factorOperator.text + " " + $factor.line;} )*;

unArithOperator : '+' | '-';

binArithOperator : '+' | '-' | 'or';

factorOperator : '*' | 'div' | 'mod' | 'and';

factor returns [String line]: 
	IDENT  selector {$line = $IDENT.text + $selector.text;}
	| INTEGER {$line = $INTEGER.text;}
	| '('  expression  ')' {$line = "(" + $expression.line + ")";}
	| 'not'  factor {$line = "not " + $factor.line;};

selector returns [String line]
	@init {$line = "";}
	:('.'  IDENT {$line += "." + $IDENT.text;} | '['  expression  ']' {$line += "[" + $expression.line + "]";} )*;

INTEGER : DIGIT (DIGIT)*;

IDENT : LETTER (LETTER | DIGIT)*;

DIGIT : '0'..'9';

LETTER : 'a' .. 'z' | 'A' .. 'Z';

WS : [ \t\r\n]+ -> skip;
