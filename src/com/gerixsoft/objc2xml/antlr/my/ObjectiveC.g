grammar ObjectiveC;

options {
	language = Java;
	output = AST;
}

tokens {
	XML_ELEMENT;
	XML_ATTRIBUTE;
}

@lexer::header {
package com.gerixsoft.objc2xml.antlr.my;
}

@header {
package com.gerixsoft.objc2xml.antlr.my;
}

translation_unit :
	external_declaration+ EOF
-> ^(XML_ELEMENT["objective-c"] external_declaration+ )
	;

external_declaration :
	ignore_enum
	| ignore_struct
	| ignore_typedef
	| interface_declaration
	| class_declaration_list
	| macro_call ';'?
	;

ignore_braces :
	'{'
	(
	ignore_braces
	| constant
	| '*'
	| ';'
	| '['
	| ']'
	| ':'
	| '='
	| ','
	| '('
	| ')'
	| '-'
	| '<'
	| '>'
	| '|'
	| '^'
	| '@private'
	| '@protected'
	| '@public'
	| 'enum'
	| 'struct'
	)*
	'}'
	;

ignore_enum :
	'enum' ignore_braces ';'
	;

ignore_struct :
	'struct' constant? ignore_braces? ';'
	;

ignore_typedef :
	'typedef'
	(
	constant
	| '*'
	| '-'
	| '('
	| ')'
	| ','
	| '<'
	| '>'
	| 'enum'
	| 'struct'
	| ignore_braces
	)+
	';'
	;

class_declaration_list :
	'@class' identifier_list ';'
	;

interface_declaration :
	(
	'@interface'
	| '@protocol'
	)
	(
	identifier_list ';'
	| class_name = Identifier (':' superclass_name = Identifier)? ('(' category_name = Identifier ')')? ('<' identifier_list '>')? ignore_braces?
	(
	'@optional'
	| '@required'
	| class_method_declaration
	| instance_method_declaration
	| ignore_property
	| ignore_enum
	| ignore_typedef
	//| interface_declaration
	)*
	'@end'
	)
	;

ignore_property :
	'@property'
	(
	constant
	| '*'
	| '('
	| ')'
	| '='
	| ','
	| '<'
	| '>'
	)+
	';'
	;

class_method_declaration :
	'+' method_declaration
	;

instance_method_declaration :
	'-' method_declaration
	;

method_declaration :
	type_name Identifier (method_argument0 method_argumentN*)? (',' '...')? macro_call? ';'
	;

method_argument0 :
	':' type_name? Identifier
	;

method_argumentN :
	Identifier ':' type_name Identifier
	;

type_name :
	'('
	(
	constant
	| '*'
	| '^'
	| '<'
	| '>'
	| '['
	| ']'
	| ','
	| type_name
	)+
	')'
	;

macro_call :
	Identifier '(' constant (',' constant)* ')'
	;

identifier_list :
	Identifier (',' Identifier)*
	;

constant :
	Identifier
	| Integer
	| Hex
	;

Identifier :
	Letter
	(
	Letter
	| '0'..'9'
	)*
	;

fragment Letter :
	'$'
	| 'A'..'Z'
	| 'a'..'z'
	| '_'
	;

Character :
	'\''
	(
	EscapeSequence
	|
	~(
	'\''
	| '\\'
	 )
	)
	'\''
	;

String :
	'"'
	(
	EscapeSequence
	|
	~(
	'\\'
	| '"'
	 )
	)*
	'"'
	;

Hex :
	'0'
	(
	'x'
	| 'X'
	)
	HexDigit+ IntegerTypeSuffix?
	;

Integer :
	(
	'0'
	| '1'..'9'
	(
	'0'..'9'
	| '_'
	)*
	)
	IntegerTypeSuffix?
	;

Octal :
	'0' ('0'..'7')+ IntegerTypeSuffix?
	;

fragment HexDigit :
	(
	'0'..'9'
	| 'a'..'f'
	| 'A'..'F'
	)
	;

fragment IntegerTypeSuffix :
	(
	'u'
	| 'U'
	| 'l'
	| 'L'
	)
	;

FloatingPoint :
	('0'..'9')+ ('.' ('0'..'9')*)? Exponent? FloatTypeSuffix?
	;

fragment Exponent :
	(
	'e'
	| 'E'
	)
	(
	'+'
	| '-'
	)?
	('0'..'9')+
	;

fragment FloatTypeSuffix :
	(
	'f'
	| 'F'
	| 'd'
	| 'D'
	)
	;

fragment EscapeSequence :
	'\\'
	(
	'b'
	| 't'
	| 'n'
	| 'f'
	| 'r'
	| '\"'
	| '\''
	| '\\'
	)
	| OctalEscape
	;

fragment OctalEscape :
	'\\' ('0'..'3') ('0'..'7') ('0'..'7')
	| '\\' ('0'..'7') ('0'..'7')
	| '\\' ('0'..'7')
	;

fragment UnicodeEscape :
	'\\' 'u' HexDigit HexDigit HexDigit HexDigit
	;

WS :
	(
	' '
	| '\r'
	| '\t'
	| '\u000C'
	| '\n'
	)
	
 {
  $channel = HIDDEN;
 }
	;

Comment :
	'/*' (options {greedy=false;}: .)* '*/' 
                                        {
                                         $channel = HIDDEN;
                                        }
	;

LineComment :
	'//'
	~(
	'\n'
	| '\r'
	 )*
	'\r'? '\n' 
           {
            $channel = HIDDEN;
           }
	;

LineCommand :
	(
	'#'
	| 'extern'
	| 'APPKIT_EXTERN'
	| 'FOUNDATION_EXPORT'
	)
	~(
	'\n'
	| '\r'
	 )*
	'\r'? '\n' 
           {
            $channel = HIDDEN;
           }
	;
