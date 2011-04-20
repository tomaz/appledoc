//
//  RelaxParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/15/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "RelaxParser.h"

@implementation RelaxParser

- (PKTokenizer *)tokenizer {
	if (!tokenizer) {
		self.tokenizer = [PKTokenizer tokenizer];
		[tokenizer.symbolState add:@"|="];
		[tokenizer.symbolState add:@"&="];
	}
	return tokenizer;
}

// topLevel ::= decl* (pattern | grammarContent*)
- (PKCollectionParser *)topLevelParser {
	if (!topLevelParser) {
		self.topLevelParser = [PKSequence sequence];
		
		PKAlternation *a = [PKAlternation alternation];
		[a add:[PKEmpty empty]];
		[a add:self.declParser];
		[topLevelParser add:a];
		
		a = [PKAlternation alternation];
		[a add:self.patternParser];
		[a add:[PKRepetition repetitionWithSubparser:self.grammarContentParser]];
		[topLevelParser add:a];
	}
	return topLevelParser;
}

// decl ::= "namespace" identifierOrKeyword "=" namespaceURILiteral
// | "default" "namespace" [identifierOrKeyword] "=" namespaceURILiteral
// | "datatypes" identifierOrKeyword "=" literal
- (PKCollectionParser *)declParser {
	if (!declParser) {
		self.declParser = [PKAlternation alternation];
		
		PKSequence *s = [PKSequence sequence];
		[s add:[PKLiteral literalWithString:@"namespace"]];
		[s add:self.identifierOrKeywordParser];
		[s add:[PKSymbol symbolWithString:@"="]];
		[a add:self.namespaceURILiteralParser];
		[declParser add:s];
		
		s = [PKSequence sequence];
		[s add:[PKLiteral literalWithString:@"default"]];
		[s add:[PKLiteral literalWithString:@"namespace"]];
		[s add:self.identifierOrKeywordParser];
		[s add:[PKSymbol symbolWithString:@"="]];
		[a add:self.namespaceURILiteralParser];
		[declParser add:s];
		
		s = [PKSequence sequence];
		[s add:[PKLiteral literalWithString:@"datatypes"]];
		[s add:self.identifierOrKeywordParser];
		[s add:[PKSymbol symbolWithString:@"="]];
		[a add:[PKQuotedString quotedString]];
		[declParser add:s];		
	}
	return declParser;
}


- (PKCollectionParser *)atLeastOneOf:(PKParser *)p {
	PKSequence *s = [PKSequence sequence];
	[s add:p];
	[s add:[PKRepetition repetitionWithSubparser:p]];
	return s;
}

// pattern ::= 
//  elementPattern
// | attributePattern
// | pattern commaPattern+
// | pattern andPattern+
// | pattern orPattern+
// | patternQuestion
// | patternStar
// | patternPlus
// | listPattern
// | mixedPattern
// | identifier
// | parent
// | emptyKeyword
// | textKeyword
// | [datatypeName] datatypeValue
// | datatypeName ["{" param* "}"] [exceptPattern]
// | "notAllowed"
// | "external" anyURILiteral [inherit]
// | "grammar" "{" grammarContent* "}"
// | "(" pattern ")"
- (PKCollectionParser *)patternParser {
	if (!patternParser) {
		self.patternParser = [PKAlternation alternation];
		[patternParser add:self.elementPatternParser];
		[patternParser add:self.attributePatternParser];
		[patternParser add:[self atLeastOneOf:self.commaPatternParser]];
		[patternParser add:[self atLeastOneOf:self.andPatternParser]];
		[patternParser add:[self atLeastOneOf:self.orPatternParser]];
		[patternParser add:[self atLeastOneOf:self.patternQuestionParser]];
		[patternParser add:[self atLeastOneOf:self.patternStarParser]];
		[patternParser add:[self atLeastOneOf:self.patternPlusParser]];
		[patternParser add:self.listPatternParser];
		[patternParser add:self.mixedPatternParser];
		[patternParser add:self.identifierParser];
		[patternParser add:self.parentParser];
		[patternParser add:self.emptyKeywordParser];
		[patternParser add:self.textKeywordParser];
		
		
        
        
		s = [PKSequence sequence];
		[s add:patternParser];
		
	}
}

// elementPattern := "element" nameClass "{" pattern "}"
- (PKCollectionParser *)elementPatternParser {
	if (!elementPatternParser) {
		self.elementPatternParser = [PKSequence sequence];
		[elementPatternParser add:[PKLiteral literalWithString:@"element"]];
		[elementPatternParser add:self.nameClass];
		[elementPatternParser add:[PKSymbol symbolWithString:@"{"]];
		[elementPatternParser add:patternParser];
		[elementPatternParser add:[PKSymbol symbolWithString:@"}"]];
	}
	return elementPatternParser;
}


// attributePattern := "attribute" nameClass "{" pattern "}"
- (PKCollectionParser *)attributePatternParser {
	if (!attributePatternParser) {
		attributePatternParser = [PKSequence sequence];
		[attributePatternParser add:[PKLiteral literalWithString:@"attribute"]];
		[attributePatternParser add:self.nameClass];
		[attributePatternParser add:[PKSymbol symbolWithString:@"{"]];
		[attributePatternParser add:patternParser];
		[attributePatternParser add:[PKSymbol symbolWithString:@"}"]];
	}
	return attributePatternParser;
}


// commaPattern := "," pattern
- (PKCollectionParser *)commaPatternParser {
	if (!commaPatternParser) {
		self.commaPatternParser = [PKSequence sequence];
		[commaPatternParser add:[PKSymbol symbolWithString:@","]];
		[commaPatternParser add:self.patternParser];
	}
	return commaPatternParser;
}


// andPattern := "&" pattern
- (PKCollectionParser *)andPatternParser {
	if (!andPatternParser) {
		self.andPatternParser = [PKSequence sequence];
		[andPatternParser add:[PKSymbol symbolWithString:@"&"]];
		[andPatternParser add:self.patternParser];
	}
	return andPatternParser;
}


// orPattern := "|" pattern
- (PKCollectionParser *)orPatternParser {
	if (!orPatternParser) {
		self.orPatternParser = [PKSequence sequence];
		[orPatternParser add:[PKSymbol symbolWithString:@"|"]];
		[orPatternParser add:self.patternParser];
	}
	return orPatternParser;
}


// patternQuestion := pattern "?"
- (PKCollectionParser *)patternQuestionParser {
	if (!patternQuestionParser) {
		self.patternQuestionParser = [PKSequence sequence];
		[patternQuestionParser add:self.patternParser];
		[patternQuestionParser add:[PKSymbol symbolWithString:@"?"]];
	}
	return patternQuestionParser;
}


// patternQuestion := pattern "*"
- (PKCollectionParser *)patternStarParser {
	if (!patternStarParser) {
		self.patternStarParser = [PKSequence sequence];
		[patternStarParser add:self.patternParser];
		[patternStarParser add:[PKSymbol symbolWithString:@"*"]];
	}
	return patternStarParser;
}


// patternQuestion := pattern "+"
- (PKCollectionParser *)patternPlusParser {
	if (!patternPlusParser) {
		self.patternPlusParser = [PKSequence sequence];
		[patternPlusParser add:self.patternParser];
		[patternPlusParser add:[PKSymbol symbolWithString:@"+"]];
	}
	return patternPlusParser;
}

// | "list" "{" pattern "}"
- (PKCollectionParser *)listPatternParser {
	if (!listPatternParser) {
		self.listPatternParser = [PKSequence sequence];
		[listPatternParser add:[PKLiteral literalWithString:@"list"]];
		[listPatternParser add:[PKSymbol symbolWithString:@"{"]];
		[listPatternParser add:patternParser];
		[listPatternParser add:[PKSymbol symbolWithString:@"}"]];
	}
	return listPatternParser;
}

// | "mixed" "{" pattern "}"
- (PKCollectionParser *)mixedPatternParser {
	if (!mixedPatternParser) {
		self.mixedPatternParser = [PKSequence sequence];
		[mixedPatternParser add:[PKLiteral literalWithString:@"mixed"]];
		[mixedPatternParser add:[PKSymbol symbolWithString:@"{"]];
		[mixedPatternParser add:patternParser];
		[mixedPatternParser add:[PKSymbol symbolWithString:@"}"]];
	}
	return mixedPatternParser;
}

// | "parent" identifier
- (PKCollectionParser *)parentParser {
	if (!parentParser) {
		self.parentParser = [PKSequence sequence];
		[parentParser add:[PKLiteral literalWithString:@"parent"]];
		[parentParser add:self.identifierParser];
	}
	return parentParser;
}


// param ::= identifierOrKeyword "=" literal
- (PKCollectionParser *)paramParser {
	if (!paramParser) {
		self.paramParser = [PKSequence sequence];
		[paramParser add:self.identifierOrKeywordParser];
		[paramParser add:[PKSymbol symbolWithString:@"="]];
		[paramParser add:self.literalParser];
	}
	return paramParser;
}

// exceptPattern ::= "-" pattern
- (PKCollectionParser *)exceptPatternParser {
	if (!exceptPattern) {
		self.exceptPattern = [PKSequence sequence];
		[exceptPattern add:[PKSymbol symbolWithString:@"-"]];
		[exceptPattern add:self.patternParser];
	}
	return exceptPattern;
}


//    grammarContent ::= start | define | "element" "{" grammarContent* "}" | "include" anyURILiteral [inherit] ["{" includeContent* "}"]
//
//    includeContent ::= define | start | elementIncludeContent
- (PKCollectionParser *)includeContentParser {
	if (!includeContentParser) {
		self.includeContentParser = [PKAlternation alternation];
		[includeContentParser add:self.defineParser];
		[includeContentParser add:self.startParser];
		[includeContentParser add:self.elementIncludeContentParser];
	}
	return includeContentParser;
}

// elementIncludeContent ::= "element" "{" includeContent* "}"
- (PKCollectionParser *)elementIncludeContentParser {
	if (!elementIncludeContentParser) {
		self.elementIncludeContentParser = [PKSequence sequence];
		[s add:self.elementKeywordParser];
		[s add:[PKSymbol symbolWithString:@"{"]];
		[s add:[PKRepetition repetitionWithSubparser:self.includeContentParser]]
		[s add:[PKSymbol symbolWithString:@"}"]];
		
		[elementIncludeContentParser add:s];
	}
	return elementIncludeContentParser;
}


//
//    start ::= "start" assignMethod pattern
- (PKCollectionParser *)startParser {
	if (!startParser) {
		self.startParser = [PKSequence sequence];
		[startParser add:self.startKeywordParser];
		[startParser add:self.assignMethodParser];
		[startParser add:self.patternParser];
	}
	return startParser;
}


//
//    define ::= identifier assignMethod pattern
- (PKCollectionParser *)defineParser {
	if (!defineParser) {
		self.defineParser = [PKSequence sequence];
		[defineParser add:self.identifierParser];
		[defineParser add:self.assignMethodParser];
		[defineParser add:self.patternParser];
	}
	return defineParser;
}


//
//    assignMethod ::= "=" | "|=" | "&="
- (PKCollectionParser *)assignMethodParser {
	if (!assignMethodParser) {
		self.assignMethodParser = [PKAlternation alternation];
		[assignMethodParser add:[PKSymbol symbolWithString:@"="]];
		[assignMethodParser add:[PKSymbol symbolWithString:@"|="]];
		[assignMethodParser add:[PKSymbol symbolWithString:@"&="]];
	}
	return assignMethodParser;
}

//
//    nameClass ::= name
//    | nsName [exceptNameClass]
//    | anyName [exceptNameClass]
//    | nameClass "|" nameClass
//    | "(" nameClass ")"
//
//    name ::= identifierOrKeyword | CName
- (PKCollectionParser *)nameParser {
	if (!nameParser) {
		self.nameParser = [PKAlternation alternation];
		[nameParser add:self.identifierOrKeywordParser];
		[nameParser add:self.CNameParser];
	}
	return nameParser;
}

//
//    exceptNameClass ::= "-" nameClass
- (PKCollectionParser *)exceptNameClassParser {
	if (!exceptNameClassParser) {
		self.exceptNameClassParser = [PKSequence sequence];
		[nameParser add:[PKSymbol symbolWithString:@"-"]];
		[nameParser add:self.nameClassParser];
	}
	return nameParser;
}

//
//    datatypeName ::= CName | "string" | "token"
- (PKCollectionParser *)datatypeNameParser {
	if (!datatypeNameParser) {
		self.datatypeNameParser = [PKAlternation alternation];
		[datatypeNameParser add:self.CNameParser];
		[datatypeNameParser add:self.stringKeywordParser];
		[datatypeNameParser add:self.tokenKeywordParser];
	}
	return datatypeNameParser;
}


//
//    datatypeValue ::= literal
- (PKCollectionParser *)datatypeValueParser {
	if (!datatypeValueParser) {
		self.datatypeValueParser = self.literalParser;
	}
	return datatypeValueParser;
}


//
//    anyURILiteral ::= literal
- (PKCollectionParser *)anyURILiteralParser {
	if (!anyURILiteralParser) {
		self.anyURILiteralParser = self.literalParser;
	}
	return anyURILiteralParser;
}


//
//    namespaceURILiteral ::= literal | "inherit"
//
//    inherit ::= "inherit" "=" identifierOrKeyword
//
//    identifierOrKeyword ::= identifier | keyword
//
//    identifier ::= (NCName - keyword) | quotedIdentifier
//
//    quotedIdentifier ::= "\" NCName
//
//    CName ::= NCName ":" NCName
//
//    nsName ::= NCName ":*"
//
//    anyName ::= "*"
//
//    literal ::= literalSegment ("~" literalSegment)+
//
//    literalSegment ::= '"' (Char - ('"' | newline))* '"'
//    | "'" (Char - ("'" | newline))* "'"
//    | '"""' (['"'] ['"'] (Char - '"'))* '"""'
//    | "'''" (["'"] ["'"] (Char - "'"))* "'''"


// keyword ::= "attribute"
// | "default"
// | "datatypes"
// | "element"
// | "empty"
// | "external"
// | "grammar"
// | "include"
// | "inherit"
// | "list"
// | "mixed"
// | "namespace"
// | "notAllowed"
// | "parent"
// | "start"
// | "string"
// | "text"
// | "token"
// 
- (PKParser *)keywordParser {
	if (!keywordParser) {
		self.keywordParser = [PKAlternation alternation];
		[keywordParser add:self.attributeKeywordParser];
		[keywordParser add:self.defaultKeywordParser];
		[keywordParser add:self.datatypesKeywordParser];
		[keywordParser add:self.elementKeywordParser];
		[keywordParser add:self.emptyKeywordParser];
		[keywordParser add:self.externalKeywordParser];
		[keywordParser add:self.grammarKeywordParser];
		[keywordParser add:self.includeKeywordParser];
		[keywordParser add:self.inheritKeywordParser];
		[keywordParser add:self.listKeywordParser];
		[keywordParser add:self.mixedKeywordParser];
		[keywordParser add:self.namespaceKeywordParser];
		[keywordParser add:self.notAllowedKeywordParser];
		[keywordParser add:self.parentKeywordParser];
		[keywordParser add:self.startKeywordParser];
		[keywordParser add:self.stringKeywordParser];
		[keywordParser add:self.textParser];
		[keywordParser add:self.tokenKeywordParser];
	}
	return keywordParser;
}


- (PKParser *)attributeKeywordParser {
	if (!attributeKeywordParser) {
		self.attributeKeywordParser = [PKLiteral literalWithString:@"attribute"];
	}
	return attributeKeywordParser;
}


- (PKParser *)defaultKeywordParser {
	if (!defaultKeywordParser) {
		self.defaultKeywordParser = [PKLiteral literalWithString:@"default"];
	}
	return defaultKeywordParser;
}


- (PKParser *)datatypesKeywordParser {
	if (!datatypesKeywordParser) {
		self.datatypesKeywordParser = [PKLiteral literalWithString:@"datatypes"];
	}
	return datatypesKeywordParser;
}


- (PKParser *)elementKeywordParser {
	if (!elementKeywordParser) {
		self.elementKeywordParser = [PKLiteral literalWithString:@"element"];
	}
	return elementKeywordParser;
}


- (PKParser *)emptyKeywordParser {
	if (!emptyKeywordParser) {
		self.emptyKeywordParser = [PKLiteral literalWithString:@"empty"];
	}
	return emptyKeywordParser;
}


- (PKParser *)externalKeywordParser {
	if (!externalKeywordParser) {
		self.externalKeywordParser = [PKLiteral literalWithString:@"external"];
	}
	return externalKeywordParser;
}


- (PKParser *)grammarKeywordParser {
	if (!grammarKeywordParser) {
		self.grammarKeywordParser = [PKLiteral literalWithString:@"grammar"];
	}
	return grammarKeywordParser;
}


- (PKParser *)includeKeywordParser {
	if (!includeKeywordParser) {
		self.includeKeywordParser = [PKLiteral literalWithString:@"include"];
	}
	return includeKeywordParser;
}


- (PKParser *)inheritKeywordParser {
	if (!inheritKeywordParser) {
		self.inheritKeywordParser = [PKLiteral literalWithString:@"inherit"];
	}
	return inheritKeywordParser;
}


- (PKParser *)listKeywordParser {
	if (!listKeywordParser) {
		self.listKeywordParser = [PKLiteral literalWithString:@"list"];
	}
	return listKeywordParser;
}


- (PKParser *)mixedKeywordParser {
	if (!mixedKeywordParser) {
		self.mixedKeywordParser = [PKLiteral literalWithString:@"mixed"];
	}
	return mixedKeywordParser;
}


- (PKParser *)namespaceKeywordParser {
	if (!namespaceKeywordParser) {
		self.namespaceKeywordParser = [PKLiteral literalWithString:@"namespace"];
	}
	return namespaceKeywordParser;
}


- (PKParser *)notAllowedKeywordParser {
	if (!notAllowedKeywordParser) {
		self.notAllowedKeywordParser = [PKLiteral literalWithString:@"notAllowed"];
	}
	return notAllowedKeywordParser;
}


- (PKParser *)parentKeywordParser {
	if (!parentKeywordParser) {
		self.parentKeywordParser = [PKLiteral literalWithString:@"parent"];
	}
	return parentKeywordParser;
}


- (PKParser *)startKeywordParser {
	if (!startKeywordParser) {
		self.startKeywordParser = [PKLiteral literalWithString:@"start"];
	}
	return startKeywordParser;
}


- (PKParser *)stringKeywordParser {
	if (!stringKeywordParser) {
		self.stringKeywordParser = [PKLiteral literalWithString:@"string"];
	}
	return stringKeywordParser;
}


- (PKParser *)textKeywordParser {
	if (!textKeywordParser) {
		self.textKeywordParser = [PKLiteral literalWithString:@"text"];
	}
	return textKeywordParser;
}


- (PKParser *)tokenKeywordParser {
	if (!tokenKeywordParser) {
		self.tokenKeywordParser = [PKLiteral literalWithString:@"token"];
	}
	return tokenKeywordParser;
}

@end
