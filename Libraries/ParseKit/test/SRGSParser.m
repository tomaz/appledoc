//
//  SRGSParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "SRGSParser.h"
#import "NSString+ParseKitAdditions.h"

@interface SRGSParser ()
- (void)didMatchWord:(PKAssembly *)a;
- (void)didMatchNum:(PKAssembly *)a;
- (void)didMatchQuotedString:(PKAssembly *)a;
- (void)didMatchStar:(PKAssembly *)a;
- (void)didMatchQuestion:(PKAssembly *)a;
- (void)didMatchAnd:(PKAssembly *)a;
- (void)didMatchOr:(PKAssembly *)a;
- (void)didMatchAssignment:(PKAssembly *)a;
- (void)didMatchVariable:(PKAssembly *)a;
@end

@implementation SRGSParser

- (id)init {
    if (self = [super init]) {
        [self add:self.grammar];
    }
    return self;
}


- (void)dealloc {
    self.selfIdentHeader = nil;
    self.ruleName = nil;
    self.tagFormat = nil;
    self.lexiconURI = nil;
    self.weight = nil;
    self.repeat = nil;
    self.probability = nil;
    self.externalRuleRef = nil;
    self.token = nil;
    self.languageAttachment = nil;
    self.tag = nil;
    self.grammar = nil;
    self.declaration = nil;
    self.baseDecl = nil;
    self.languageDecl = nil;
    self.modeDecl = nil;
    self.rootRuleDecl = nil;
    self.tagFormatDecl = nil;
    self.lexiconDecl = nil;
    self.metaDecl = nil;
    self.tagDecl = nil;
    self.ruleDefinition = nil;
    self.scope = nil;
    self.ruleExpansion = nil;
    self.ruleAlternative = nil;
    self.sequenceElement = nil;
    self.subexpansion = nil;
    self.ruleRef = nil;
    self.localRuleRef = nil;
    self.specialRuleRef = nil;
    self.repeatOperator = nil;
    
    self.baseURI = nil;
    self.languageCode = nil;
    self.ABNF_URI = nil;
    self.ABNF_URI_with_Media_Type = nil;
    [super dealloc];
}


- (id)parse:(NSString *)s {
    PKAssembly *a = [self assemblyWithString:s];
    a = [self completeMatchFor:a];
    return [a pop];
}


- (PKAssembly *)assemblyWithString:(NSString *)s {
    PKTokenizer *t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    [t setTokenizerState:t.symbolState from: '-' to: '-'];
    [t setTokenizerState:t.symbolState from: '.' to: '.'];
    //[t.wordState setWordChars:YES from:'-' to:'-'];

    PKTokenAssembly *a = [PKTokenAssembly assemblyWithTokenizer:t];
    //    TDNCNameState *NCNameState = [[[TDNCNameState alloc] init] autorelease];
    return a;
}


//selfIdentHeader ::= '#ABNF' #x20 VersionNumber (#x20 CharEncoding)? ';'
//VersionNumber    ::= '1.0'
//CharEncoding     ::= Nmtoken
- (PKCollectionParser *)selfIdentHeader {
    if (!selfIdentHeader) {
        self.selfIdentHeader = [PKSequence sequence];
        selfIdentHeader.name = @"selfIdentHeader";
        
        [selfIdentHeader add:[PKSymbol symbolWithString:@"#"]];
        [selfIdentHeader add:[PKLiteral literalWithString:@"ABNF"]];
        [selfIdentHeader add:[PKNumber number]];  // VersionNumber
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:[PKWord word]]; // CharEncoding
        
        [selfIdentHeader add:a];
        [selfIdentHeader add:[PKSymbol symbolWithString:@";"]];
    }
    return selfIdentHeader;
}


//RuleName         ::= '$' ConstrainedName 
//ConstrainedName  ::= Name - (Char* ('.' | ':' | '-') Char*)
- (PKCollectionParser *)ruleName {
    if (!ruleName) {
        self.ruleName = [PKSequence sequence];
        [ruleName add:[PKSymbol symbolWithString:@"$"]];
        [ruleName add:[PKWord word]]; // TODO: ConstrainedName
    }
    return ruleName;
}

//TagFormat ::= ABNF_URI
- (PKCollectionParser *)tagFormat {
    if (!tagFormat) {
        self.tagFormat = self.ABNF_URI;
    }
    return tagFormat;
}


//LexiconURI ::= ABNF_URI | ABNF_URI_with_Media_Type
- (PKCollectionParser *)lexiconURI {
    if (!lexiconURI) {
        self.lexiconURI = [PKAlternation alternation];
        [lexiconURI add:self.ABNF_URI];
        [lexiconURI add:self.ABNF_URI_with_Media_Type];
    }
    return lexiconURI;
}


//Weight ::= '/' Number '/'
- (PKCollectionParser *)weight {
    if (!weight) {
        self.weight = [PKSequence sequence];
        [weight add:[PKSymbol symbolWithString:@"/"]];
        [weight add:[PKNumber number]];
        [weight add:[PKSymbol symbolWithString:@"/"]];
    }
    return weight;
}


//Repeat ::= [0-9]+ ('-' [0-9]*)?
- (PKCollectionParser *)repeat {
    if (!repeat) {
        self.repeat = [PKSequence sequence];
        [repeat add:[PKNumber number]];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"-"]];
        [s add:[PKNumber number]];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:s];
        
        [repeat add:a];
    }
    return repeat;
}


//Probability      ::= '/' Number '/'
- (PKCollectionParser *)probability {
    if (!probability) {
        self.probability = [PKSequence sequence];
        [probability add:[PKSymbol symbolWithString:@"/"]];
        [probability add:[PKNumber number]];
        [probability add:[PKSymbol symbolWithString:@"/"]];
    }
    return probability;
}



//ExternalRuleRef  ::= '$' ABNF_URI | '$' ABNF_URI_with_Media_Type
- (PKCollectionParser *)externalRuleRef {
    if (!externalRuleRef) {
        self.externalRuleRef = [PKAlternation alternation];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"$"]];
        [s add:self.ABNF_URI];
        [externalRuleRef add:s];

        s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"$"]];
        [s add:self.ABNF_URI_with_Media_Type];
        [externalRuleRef add:s];
    }
    return externalRuleRef;
}


//Token  ::= Nmtoken | DoubleQuotedCharacters
- (PKCollectionParser *)token {
    if (!token) {
        self.token = [PKAlternation alternation];
        [token add:[PKWord word]];
        [token add:[PKQuotedString quotedString]];
    }
    return token;
}


//LanguageAttachment ::= '!' LanguageCode
- (PKCollectionParser *)languageAttachment {
    if (!languageAttachment) {
        self.languageAttachment = [PKSequence sequence];
        [languageAttachment add:[PKSymbol symbolWithString:@"!"]];
        [languageAttachment add:self.languageCode];
    }
    return languageAttachment;
}


//Tag ::= '{' [^}]* '}' | '{!{' (Char* - (Char* '}!}' Char*)) '}!}'
- (PKCollectionParser *)tag {
    if (!tag) {
        self.tag = [PKAlternation alternation];

        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"{"]];
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKWord word]];
        [a add:[PKNumber number]];
        [a add:[PKSymbol symbol]];
        [a add:[PKQuotedString quotedString]];
        [s add:[PKRepetition repetitionWithSubparser:a]];
        [s add:[PKSymbol symbolWithString:@"}"]];
        [tag add:s];
        
        s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"{!{"]];
        a = [PKAlternation alternation];
        [a add:[PKWord word]];
        [a add:[PKNumber number]];
        [a add:[PKSymbol symbol]];
        [a add:[PKQuotedString quotedString]];
        [s add:[PKRepetition repetitionWithSubparser:a]];
        [s add:[PKLiteral literalWithString:@"}!}"]];
        [tag add:s];
    }
    return tag;
}


#pragma mark -
#pragma mark Grammar

// grammar ::= selfIdentHeader declaration* ruleDefinition*
- (PKCollectionParser *)grammar {
    if (!grammar) {
        self.grammar = [PKSequence sequence];
        [grammar add:self.selfIdentHeader];
        [grammar add:[PKRepetition repetitionWithSubparser:self.declaration]];
        [grammar add:[PKRepetition repetitionWithSubparser:self.ruleDefinition]];
    }
    return grammar;
}

// declaration ::= baseDecl | languageDecl | modeDecl | rootRuleDecl | tagFormatDecl | lexiconDecl | metaDecl | tagDecl
- (PKCollectionParser *)declaration {
    if (!declaration) {
        self.declaration = [PKAlternation alternation];
        [declaration add:self.baseDecl];
        [declaration add:self.languageDecl];
        [declaration add:self.modeDecl];
        [declaration add:self.rootRuleDecl];
        [declaration add:self.tagFormatDecl];
        [declaration add:self.lexiconDecl];
        [declaration add:self.tagDecl];
    }
    return declaration;
}

// baseDecl ::= 'base' BaseURI ';'
- (PKCollectionParser *)baseDecl {
    if (!baseDecl) {
        self.baseDecl = [PKSequence sequence];
        [baseDecl add:[PKLiteral literalWithString:@"base"]];
        [baseDecl add:self.baseURI];
        [baseDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return baseDecl;
}

// languageDecl    ::= 'language' LanguageCode ';'
- (PKCollectionParser *)languageDecl {
    if (!languageDecl) {
        self.languageDecl = [PKSequence sequence];
        [languageDecl add:[PKLiteral literalWithString:@"language"]];
        [languageDecl add:self.languageCode];
        [languageDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return languageDecl;
}



// modeDecl        ::= 'mode' 'voice' ';' | 'mode' 'dtmf' ';'
- (PKCollectionParser *)modeDecl {
    if (!modeDecl) {
        self.modeDecl = [PKAlternation alternation];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"mode"]];
        [s add:[PKLiteral literalWithString:@"voice"]];
        [s add:[PKSymbol symbolWithString:@";"]];
        [modeDecl add:s];
        
        s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"mode"]];
        [s add:[PKLiteral literalWithString:@"dtmf"]];
        [s add:[PKSymbol symbolWithString:@";"]];
        [modeDecl add:s];
    }
    return modeDecl;
}


// rootRuleDecl    ::= 'root' RuleName ';'
- (PKCollectionParser *)rootRuleDecl {
    if (!rootRuleDecl) {
        self.rootRuleDecl = [PKSequence sequence];
        [rootRuleDecl add:[PKLiteral literalWithString:@"root"]];
        [rootRuleDecl add:self.ruleName];
        [rootRuleDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return rootRuleDecl;
}


// tagFormatDecl   ::=     'tag-format' TagFormat ';'
- (PKCollectionParser *)tagFormatDecl {
    if (!tagFormatDecl) {
        self.tagFormatDecl = [PKSequence sequence];
        [tagFormatDecl add:[PKLiteral literalWithString:@"tag-format"]];
        [tagFormatDecl add:self.tagFormat];
        [tagFormatDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return tagFormatDecl;
}



// lexiconDecl     ::= 'lexicon' LexiconURI ';'
- (PKCollectionParser *)lexiconDecl {
    if (!lexiconDecl) {
        self.lexiconDecl = [PKSequence sequence];
        [lexiconDecl add:[PKLiteral literalWithString:@"lexicon"]];
        [lexiconDecl add:self.lexiconURI];
        [lexiconDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return lexiconDecl;
}


// metaDecl        ::=
//    'http-equiv' QuotedCharacters 'is' QuotedCharacters ';'
//    | 'meta' QuotedCharacters 'is' QuotedCharacters ';'
- (PKCollectionParser *)metaDecl {
    if (!metaDecl) {
        self.metaDecl = [PKAlternation alternation];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"http-equiv"]];
        [s add:[PKQuotedString quotedString]];
        [s add:[PKLiteral literalWithString:@"is"]];
        [s add:[PKQuotedString quotedString]];
        [s add:[PKSymbol symbolWithString:@";"]];
        [metaDecl add:s];
        
        s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"meta"]];
        [s add:[PKQuotedString quotedString]];
        [s add:[PKLiteral literalWithString:@"is"]];
        [s add:[PKQuotedString quotedString]];
        [s add:[PKSymbol symbolWithString:@";"]];
        [metaDecl add:s];
    }
    return metaDecl;
}



// tagDecl  ::=  Tag ';'
- (PKCollectionParser *)tagDecl {
    if (!tagDecl) {
        self.tagDecl = [PKSequence sequence];
        [tagDecl add:self.tag];
        [tagDecl add:[PKSymbol symbolWithString:@";"]];
    }
    return tagDecl;
}


// ruleDefinition  ::= scope? RuleName '=' ruleExpansion ';'
- (PKCollectionParser *)ruleDefinition {
    if (!ruleDefinition) {
        self.ruleDefinition = [PKSequence sequence];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.scope];
        
        [ruleDefinition add:a];
        [ruleDefinition add:self.ruleName];
        [ruleDefinition add:[PKSymbol symbolWithString:@"="]];
        [ruleDefinition add:self.ruleExpansion];
        [ruleDefinition add:[PKSymbol symbolWithString:@";"]];
    }
    return ruleDefinition;
}

// scope ::=  'private' | 'public'
- (PKCollectionParser *)scope {
    if (!scope) {
        self.scope = [PKAlternation alternation];
        [scope add:[PKLiteral literalWithString:@"private"]];
        [scope add:[PKLiteral literalWithString:@"public"]];
    }
    return scope;
}


// ruleExpansion   ::= ruleAlternative ( '|' ruleAlternative )*
- (PKCollectionParser *)ruleExpansion {
    if (!ruleExpansion) {
        self.ruleExpansion = [PKSequence sequence];
        [ruleExpansion add:self.ruleAlternative];
        
        PKSequence *pipeRuleAlternative = [PKSequence sequence];
        [pipeRuleAlternative add:[PKSymbol symbolWithString:@"|"]];
        [pipeRuleAlternative add:self.ruleAlternative];
        [ruleExpansion add:[PKRepetition repetitionWithSubparser:pipeRuleAlternative]];
    }
    return ruleExpansion;
}


// ruleAlternative ::= Weight? sequenceElement+
- (PKCollectionParser *)ruleAlternative {
    if (!ruleAlternative) {
        self.ruleAlternative = [PKSequence sequence];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.weight];
        
        [ruleAlternative add:a];
        [ruleAlternative add:self.sequenceElement];
        [ruleAlternative add:[PKRepetition repetitionWithSubparser:self.sequenceElement]];
    }
    return ruleAlternative;
}

// sequenceElement ::= subexpansion | subexpansion repeatOperator

// me: changing to: 
// sequenceElement ::= subexpansion repeatOperator?
- (PKCollectionParser *)sequenceElement {
    if (!sequenceElement) {
//        self.sequenceElement = [PKAlternation alternation];
//        [sequenceElement add:self.subexpansion];
//        
//        PKSequence *s = [PKSequence sequence];
//        [s add:self.subexpansion];
//        [s add:self.repeatOperator];
//        
//        [sequenceElement add:s];

        self.sequenceElement = [PKSequence sequence];
        [sequenceElement add:self.subexpansion];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.repeatOperator];
        
        [sequenceElement add:a];
    }
    return sequenceElement;
}

// subexpansion    ::=
//     Token LanguageAttachment?
//     | ruleRef 
//     | Tag
//     | '(' ')'
//     | '(' ruleExpansion ')' LanguageAttachment?
//     | '[' ruleExpansion ']' LanguageAttachment?
- (PKCollectionParser *)subexpansion {
    if (!subexpansion) {
        self.subexpansion = [PKAlternation alternation];
        
        PKSequence *s = [PKSequence sequence];
        [s add:self.token];
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.languageAttachment];
        [s add:a];
        [subexpansion add:s];
        
        [subexpansion add:self.ruleRef];
        [subexpansion add:self.tag];
        
        s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:[PKSymbol symbolWithString:@")"]];
        [subexpansion add:s];
        
        s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:self.ruleExpansion];    
        [s add:[PKSymbol symbolWithString:@")"]];
        a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.languageAttachment];
        [s add:a];
        [subexpansion add:s];
        
        s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"["]];
        [s add:self.ruleExpansion];    
        [s add:[PKSymbol symbolWithString:@"]"]];
        a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.languageAttachment];
        [s add:a];
        [subexpansion add:s];
    }
    return subexpansion;
}


// ruleRef  ::= localRuleRef | ExternalRuleRef | specialRuleRef
- (PKCollectionParser *)ruleRef {
    if (!ruleRef) {
        self.ruleRef = [PKAlternation alternation];
        [ruleRef add:self.localRuleRef];
        [ruleRef add:self.externalRuleRef];
        [ruleRef add:self.specialRuleRef];
    }
    return ruleRef;
}

// localRuleRef    ::= RuleName
- (PKCollectionParser *)localRuleRef {
    if (!localRuleRef) {
        self.localRuleRef = self.ruleName;
    }
    return localRuleRef;
}


// specialRuleRef  ::= '$NULL' | '$VOID' | '$GARBAGE'
- (PKCollectionParser *)specialRuleRef {
    if (!specialRuleRef) {
        self.specialRuleRef = [PKAlternation alternation];
        [specialRuleRef add:[PKLiteral literalWithString:@"$NULL"]];
        [specialRuleRef add:[PKLiteral literalWithString:@"$VOID"]];
        [specialRuleRef add:[PKLiteral literalWithString:@"$GARBAGE"]];
    }
    return specialRuleRef;
}


// repeatOperator  ::='<' Repeat Probability? '>'
- (PKCollectionParser *)repeatOperator {
    if (!repeatOperator) {
        self.repeatOperator = [PKSequence sequence];
        [repeatOperator add:[PKSymbol symbolWithString:@"<"]];
        [repeatOperator add:self.repeat];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.probability];
        [repeatOperator add:a];
        
        [repeatOperator add:[PKSymbol symbolWithString:@">"]];
    }
    return repeatOperator;
}


//BaseURI ::= ABNF_URI
- (PKCollectionParser *)baseURI {
    if (!baseURI) {
        self.baseURI = [PKWord word];
    }
    return baseURI;
}


//LanguageCode ::= Nmtoken
- (PKCollectionParser *)languageCode {
    if (!languageCode) {
        self.languageCode = [PKSequence sequence];
        [languageCode add:[PKWord word]];
//        [languageCode add:[PKSymbol symbolWithString:@"-"]];
//        [languageCode add:[PKWord word]];
    }
    return languageCode;
}


- (PKCollectionParser *)ABNF_URI {
    if (!ABNF_URI) {
        self.ABNF_URI = [PKWord word];
    }
    return ABNF_URI;
}


- (PKCollectionParser *)ABNF_URI_with_Media_Type {
    if (!ABNF_URI_with_Media_Type) {
        self.ABNF_URI_with_Media_Type = [PKWord word];
    }
    return ABNF_URI_with_Media_Type;
}



#pragma mark -
#pragma mark Assembler Methods

- (void)didMatchWord:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    [a push:[PKLiteral literalWithString:tok.stringValue]];
}


- (void)didMatchNum:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    [a push:[PKLiteral literalWithString:tok.stringValue]];
}


- (void)didMatchQuotedString:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKToken *tok = [a pop];
    NSString *s = [tok.stringValue stringByTrimmingQuotes];
    
    PKSequence *p = [PKSequence sequence];
    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
    PKToken *eof = [PKToken EOFToken];
    while (eof != (tok = [t nextToken])) {
        [p add:[PKLiteral literalWithString:tok.stringValue]];
    }
    
    [a push:p];
}


- (void)didMatchStar:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKRepetition *p = [PKRepetition repetitionWithSubparser:[a pop]];
    [a push:p];
}


- (void)didMatchQuestion:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKAlternation *p = [PKAlternation alternation];
    [p add:[a pop]];
    [p add:[PKEmpty empty]];
    [a push:p];
}


- (void)didMatchAnd:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id top = [a pop];
    PKSequence *p = [PKSequence sequence];
    [p add:[a pop]];
    [p add:top];
    [a push:p];
}


- (void)didMatchOr:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id top = [a pop];
//    NSLog(@"top: %@", top);
//    NSLog(@"top class: %@", [top class]);
    PKAlternation *p = [PKAlternation alternation];
    [p add:[a pop]];
    [p add:top];
    [a push:p];
}


- (void)didMatchAssignment:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id val = [a pop];
    PKToken *keyTok = [a pop];
    
    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithDictionary:a.target];
    [table setObject:val forKey:keyTok.stringValue];
    a.target = table;
}


- (void)didMatchVariable:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    PKToken *keyTok = [a pop];
    id val = [a.target objectForKey:keyTok.stringValue];
    
//    PKParser *p = nil;
//    if (valTok.isWord) {
//        p = [PKWord wordWithString:valTok.value];
//    } else if (valTok.isQuotedString) {
//        p = [PKQuotedString quotedStringWithString:valTok.value];
//    } else if (valTok.isNumber) {
//        p = [PKNum numWithString:valTok.stringValue];
//    }
    
    [a push:val];
}

@synthesize selfIdentHeader;
@synthesize ruleName;
@synthesize tagFormat;
@synthesize lexiconURI;
@synthesize weight;
@synthesize repeat;
@synthesize probability;
@synthesize externalRuleRef;
@synthesize token;
@synthesize languageAttachment;
@synthesize tag;
@synthesize grammar;
@synthesize declaration;
@synthesize baseDecl;
@synthesize languageDecl;
@synthesize modeDecl;
@synthesize rootRuleDecl;
@synthesize tagFormatDecl;
@synthesize lexiconDecl;
@synthesize metaDecl;
@synthesize tagDecl;
@synthesize ruleDefinition;
@synthesize scope;
@synthesize ruleExpansion;
@synthesize ruleAlternative;
@synthesize sequenceElement;
@synthesize subexpansion;
@synthesize ruleRef;
@synthesize localRuleRef;
@synthesize specialRuleRef;
@synthesize repeatOperator;

@synthesize baseURI;
@synthesize languageCode;
@synthesize ABNF_URI;
@synthesize ABNF_URI_with_Media_Type;
@end