//
//  XPathParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "XPathParser.h"
//#import "TDNCName.h"

#import "TDNCNameState.h"
#import "XPathAssembler.h"

@interface XPathParser ()
@property (retain) XPathAssembler *xpathAssembler;
@end

@implementation XPathParser

- (id)init {
    if (self = [super init]) {
        self.xpathAssembler = [[[XPathAssembler alloc] init] autorelease];
        [self add:self.locationPath];
    }
    return self;
}


- (void)dealloc {
    self.xpathAssembler = nil;
    self.locationPath = nil;
    self.absoluteLocationPath = nil;
    self.relativeLocationPath = nil;
    self.step = nil;
    self.axisSpecifier = nil;
    self.axisName = nil;
    self.nodeTest = nil;
    self.predicate = nil;
    self.predicateExpr = nil;
    self.abbreviatedAbsoluteLocationPath = nil;
    self.abbreviatedRelativeLocationPath = nil;
    self.abbreviatedStep = nil;
    self.abbreviatedAxisSpecifier = nil;
    self.expr = nil;
    self.primaryExpr = nil;
    self.functionCall = nil;
    self.argument = nil;
    self.unionExpr = nil;
    self.pathExpr = nil;
    self.filterExpr = nil;
    self.orExpr = nil;
    self.andExpr = nil;
    self.equalityExpr = nil;
    self.relationalExpr = nil;
    self.additiveExpr = nil;
    self.multiplicativeExpr = nil;
    self.unaryExpr = nil;
    self.exprToken = nil;
    self.literal = nil;
    self.number = nil;
    self.operator = nil;
    self.operatorName = nil;
    self.multiplyOperator = nil;
    self.functionName = nil;
    self.variableReference = nil;
    self.nameTest = nil;
    self.nodeType = nil;
    self.QName = nil;
    [super dealloc];
}


- (PKAssembly *)assemblyWithString:(NSString *)s {
    PKTokenizer *t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    [t.symbolState add:@"::"];
    [t.symbolState add:@"!="];
    [t.symbolState add:@"<="];
    [t.symbolState add:@">="];
    [t.symbolState add:@".."];
    [t.symbolState add:@"//"];
    [t setTokenizerState:t.wordState from: '_' to: '_'];
//    [t setTokenizerState:NCNameState from: 'a' to: 'z'];
//    [t setTokenizerState:NCNameState from: 'A' to: 'Z'];
//    [t setTokenizerState:NCNameState from:0xc0 to:0xff];
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithTokenizer:t];
//    TDNCNameState *NCNameState = [[[TDNCNameState alloc] init] autorelease];
    
    return a;
}


- (id)parse:(NSString *)s {
    [xpathAssembler resetWithReader:nil];
    PKAssembly *a = [self assemblyWithString:s];
    id result = [self completeMatchFor:a];
    return result;
}


// [1]        LocationPath                        ::=       RelativeLocationPath | AbsoluteLocationPath    
- (PKCollectionParser *)locationPath {
    //NSLog(@"%s", _cmd);
    if (!locationPath) {
        self.locationPath = [PKAlternation alternation];
        locationPath.name = @"locationPath";
        
        [locationPath add:self.relativeLocationPath];
        [locationPath add:self.absoluteLocationPath];
    }
    return locationPath;
}


//[2]        AbsoluteLocationPath                ::=       '/' RelativeLocationPath? | AbbreviatedAbsoluteLocationPath    
- (PKCollectionParser *)absoluteLocationPath {
    //NSLog(@"%s", _cmd);
    if (!absoluteLocationPath) {
        self.absoluteLocationPath = [PKAlternation alternation];
        absoluteLocationPath.name = @"absoluteLocationPath";

        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.relativeLocationPath];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"/"]];
        [s add:a];
        
        [absoluteLocationPath add:s];
        [absoluteLocationPath add:self.abbreviatedAbsoluteLocationPath];
    }
    return absoluteLocationPath;
}

#pragma mark -
#pragma mark left recursion

//[3] RelativeLocationPath ::= Step    | RelativeLocationPath '/' Step    | AbbreviatedRelativeLocationPath

// avoiding left recursion by changing to this
//[3] RelativeLocationPath ::= Step SlashStep*    | AbbreviatedRelativeLocationPath

- (PKCollectionParser *)relativeLocationPath {
    //NSLog(@"%s", _cmd);
    if (!relativeLocationPath) {
        self.relativeLocationPath = [PKAlternation alternation];
        relativeLocationPath.name = @"relativeLocationPath";

        PKSequence *s = [PKSequence sequence];
        [s add:self.step];

        PKSequence *slashStep = [PKSequence sequence];
        [slashStep add:[PKSymbol symbolWithString:@"/"]];
        [slashStep add:self.step];
        [s add:[PKRepetition repetitionWithSubparser:slashStep]];

        [relativeLocationPath add:s];
        // TODO this is causing and infinite loop!
//        [relativeLocationPath add:self.abbreviatedRelativeLocationPath];
    }
    return relativeLocationPath;
}


// [4] Step ::=       AxisSpecifier NodeTest Predicate* | AbbreviatedStep    
- (PKCollectionParser *)step {
    NSLog(@"%s", _cmd);
    if (!step) {
        self.step = [PKAlternation alternation];
        step.name = @"step";
        
        PKSequence *s = [PKSequence sequence];
        [s add:self.axisSpecifier];
        [s add:self.nodeTest];
        [s add:[PKRepetition repetitionWithSubparser:self.predicate]];
        
        [step add:s];
        [step add:self.abbreviatedStep];
        
        [step setAssembler:xpathAssembler selector:@selector(didMatchStep:)];
    }
    return step;
}


// [5]    AxisSpecifier ::= AxisName '::' | AbbreviatedAxisSpecifier
- (PKCollectionParser *)axisSpecifier {
    //NSLog(@"%s", _cmd);
    if (!axisSpecifier) {
        self.axisSpecifier = [PKAlternation alternation];
        axisSpecifier.name = @"axisSpecifier";
        
        PKSequence *s = [PKSequence sequence];
        [s add:self.axisName];
        [s add:[PKSymbol symbolWithString:@"::"]];
        
        [axisSpecifier add:s];
        [axisSpecifier add:self.abbreviatedAxisSpecifier];
        [axisSpecifier setAssembler:xpathAssembler selector:@selector(didMatchAxisSpecifier:)];
    }
    return axisSpecifier;
}


// [6] AxisName ::= 'ancestor' | 'ancestor-or-self' | 'attribute' | 'child' | 'descendant' | 'descendant-or-self'
//            | 'following' | 'following-sibling' | 'namespace' | 'parent' | 'preceding' | 'preceding-sibling' | 'self'
- (PKCollectionParser *)axisName {
    //NSLog(@"%s", _cmd);
    if (!axisName) {
        self.axisName = [PKAlternation alternation];
        axisName.name = @"axisName";
        [axisName add:[PKLiteral literalWithString:@"ancestor"]];
        [axisName add:[PKLiteral literalWithString:@"ancestor-or-self"]];
        [axisName add:[PKLiteral literalWithString:@"attribute"]];
        [axisName add:[PKLiteral literalWithString:@"child"]];
        [axisName add:[PKLiteral literalWithString:@"descendant"]];
        [axisName add:[PKLiteral literalWithString:@"descendant-or-self"]];
        [axisName add:[PKLiteral literalWithString:@"following"]];
        [axisName add:[PKLiteral literalWithString:@"following-sibling"]];
        [axisName add:[PKLiteral literalWithString:@"preceeding"]];
        [axisName add:[PKLiteral literalWithString:@"preceeding-sibling"]];
        [axisName add:[PKLiteral literalWithString:@"namespace"]];
        [axisName add:[PKLiteral literalWithString:@"parent"]];
        [axisName add:[PKLiteral literalWithString:@"self"]];
    }
    return axisName;
}


// [7]  NodeTest ::= NameTest | NodeType '(' ')' | 'processing-instruction' '(' Literal ')'
- (PKCollectionParser *)nodeTest {
    //NSLog(@"%s", _cmd);
    if (!nodeTest) {
        self.nodeTest = [PKAlternation alternation];
        nodeTest.name = @"nodeTest";
        [nodeTest add:self.nameTest];
        
        PKSequence *s = [PKSequence sequence];
        [s add:self.nodeType];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:[PKSymbol symbolWithString:@")"]];
        [nodeTest add:s];
        
        s = [PKSequence sequence];
        [s add:[PKLiteral literalWithString:@"processing-instruction"]];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:self.literal];
        [s add:[PKSymbol symbolWithString:@")"]];
        [nodeTest add:s];    
    }
    return nodeTest;
}


// [8]  Predicate ::=  '[' PredicateExpr ']'    
- (PKCollectionParser *)predicate {
    //NSLog(@"%s", _cmd);
    if (!predicate) {
        self.predicate = [PKSequence sequence];
        predicate.name = @"predicate";
        [predicate add:[PKSymbol symbolWithString:@"["]];
        [predicate add:self.predicateExpr];
        [predicate add:[PKSymbol symbolWithString:@"]"]];
    }
    return predicate;
}


// [9]  PredicateExpr    ::=       Expr
- (PKCollectionParser *)predicateExpr {
    //NSLog(@"%s", _cmd);
    if (!predicateExpr) {
        self.predicateExpr = self.expr;
        predicateExpr.name = @"predicateExpr";
    }
    return predicateExpr;
}


// [10]  AbbreviatedAbsoluteLocationPath ::= '//' RelativeLocationPath    
- (PKCollectionParser *)abbreviatedAbsoluteLocationPath {
    //NSLog(@"%s", _cmd);
    if (!abbreviatedAbsoluteLocationPath) {
        self.abbreviatedAbsoluteLocationPath = [PKSequence sequence];
        abbreviatedAbsoluteLocationPath.name = @"abbreviatedAbsoluteLocationPath";
        [abbreviatedAbsoluteLocationPath add:[PKSymbol symbolWithString:@"//"]];
        [abbreviatedAbsoluteLocationPath add:self.relativeLocationPath];
    }
    return abbreviatedAbsoluteLocationPath;
}


// [11] AbbreviatedRelativeLocationPath ::= RelativeLocationPath '//' Step    
- (PKCollectionParser *)abbreviatedRelativeLocationPath {
    //NSLog(@"%s", _cmd);
    if (!abbreviatedRelativeLocationPath) {
        self.abbreviatedRelativeLocationPath = [PKSequence sequence];
        abbreviatedRelativeLocationPath.name = @"abbreviatedRelativeLocationPath";
        [abbreviatedRelativeLocationPath add:self.relativeLocationPath];
        [abbreviatedRelativeLocationPath add:[PKSymbol symbolWithString:@"//"]];
        [abbreviatedRelativeLocationPath add:self.step];
    }
    return abbreviatedRelativeLocationPath;
}


// [12] AbbreviatedStep    ::=       '.'    | '..'
- (PKCollectionParser *)abbreviatedStep {
    //NSLog(@"%s", _cmd);
    if (!abbreviatedStep) {
        self.abbreviatedStep = [PKAlternation alternation];
        abbreviatedStep.name = @"abbreviatedStep";
        [abbreviatedStep add:[PKSymbol symbolWithString:@"."]];
        [abbreviatedStep add:[PKSymbol symbolWithString:@".."]];
    }
    return abbreviatedStep;
}


// [13] AbbreviatedAxisSpecifier ::=       '@'?
- (PKCollectionParser *)abbreviatedAxisSpecifier {
    //NSLog(@"%s", _cmd);
    if (!abbreviatedAxisSpecifier) {
        self.abbreviatedAxisSpecifier = [PKAlternation alternation];
        abbreviatedAxisSpecifier.name = @"abbreviatedAxisSpecifier";
        [abbreviatedAxisSpecifier add:[PKEmpty empty]];
        [abbreviatedAxisSpecifier add:[PKSymbol symbolWithString:@"@"]];
    }
    return abbreviatedAxisSpecifier;
}


// [14]       Expr ::=       OrExpr    
- (PKCollectionParser *)expr {
    //NSLog(@"%s", _cmd);
    if (!expr) {
        self.expr = self.orExpr;
        expr.name = @"expr";
    }
    return expr;
}


// [15] PrimaryExpr    ::=  VariableReference    
//                    | '(' Expr ')'    
//                    | Literal    
//                    | Number    
//                    | FunctionCall
- (PKCollectionParser *)primaryExpr {
    //NSLog(@"%s", _cmd);
    if (!primaryExpr) {
        self.primaryExpr = [PKAlternation alternation];
        primaryExpr.name = @"primaryExpr";
        [primaryExpr add:self.variableReference];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:self.expr];
        [s add:[PKSymbol symbolWithString:@")"]];
        [primaryExpr add:s];
        
        [primaryExpr add:self.literal];
        [primaryExpr add:self.number];
        [primaryExpr add:self.functionCall];
    }
    return primaryExpr;
}


// [16] FunctionCall ::= FunctionName '(' ( Argument ( ',' Argument )* )? ')'    

// commaArg ::= ',' Argument
// [16] FunctionCall ::= FunctionName '(' ( Argument commaArg* )? ')'    
- (PKCollectionParser *)functionCall {
    //NSLog(@"%s", _cmd);
    if (!functionCall) {
        self.functionCall = [PKSequence sequence];
        functionCall.name = @"functionCall";
        [functionCall add:self.functionName];
        [functionCall add:[PKSymbol symbolWithString:@"("]];
        
        PKSequence *commaArg = [PKSequence sequence];
        [commaArg add:[PKSymbol symbolWithString:@","]];
        [commaArg add:self.argument];
        
        PKSequence *args = [PKSequence sequence];
        [args add:self.argument];
        [args add:[PKRepetition repetitionWithSubparser:commaArg]];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:args];
        
        [functionCall add:a];
        [functionCall add:[PKSymbol symbolWithString:@")"]];
    }
    return functionCall;
}


// [17] Argument ::=       Expr
- (PKCollectionParser *)argument {
    //NSLog(@"%s", _cmd);
    if (!argument) {
        self.argument = self.expr;
        argument.name = @"argument";
    }
    return argument;
}


#pragma mark -
#pragma mark Left Recursion

// [18]  UnionExpr ::=       PathExpr | UnionExpr '|' PathExpr    

// pipePathExpr :: = | PathExpr
// [18]  UnionExpr ::=       PathExpr PipePathExpr*
- (PKCollectionParser *)unionExpr {
    //NSLog(@"%s", _cmd);
    if (!unionExpr) {
        self.unionExpr = [PKSequence sequence];
        unionExpr.name = @"unionExpr";

        PKSequence *pipePathExpr = [PKSequence sequence];
        [pipePathExpr add:[PKSymbol symbolWithString:@"|"]];
        [pipePathExpr add:self.pathExpr];
        
        [unionExpr add:self.pathExpr];
        [unionExpr add:[PKRepetition repetitionWithSubparser:pipePathExpr]];
    }
    return unionExpr;
}


//[19]       PathExpr ::= LocationPath    
//                    | FilterExpr    
//                    | FilterExpr '/' RelativeLocationPath    
//                    | FilterExpr '//' RelativeLocationPath    
- (PKCollectionParser *)pathExpr {
    //NSLog(@"%s", _cmd);
    if (!pathExpr) {
        self.pathExpr = [PKAlternation alternation];
        pathExpr.name = @"pathExpr";
        [pathExpr add:self.locationPath];
        [pathExpr add:self.filterExpr];
        
        PKSequence *s = [PKSequence sequence];
        [s add:self.filterExpr];
        [s add:[PKSymbol symbolWithString:@"/"]];
        [s add:self.relativeLocationPath];
        [pathExpr add:s];
        
        s = [PKSequence sequence];
        [s add:self.filterExpr];
        [s add:[PKSymbol symbolWithString:@"//"]];
        [s add:self.relativeLocationPath];
        [pathExpr add:s];
    }
    return pathExpr;
}


#pragma mark -
#pragma mark Left Recursion????????????

// [20]  FilterExpr     ::=       PrimaryExpr    | FilterExpr Predicate


// [20]  FilterExpr     ::=       PrimaryExpr Predicate?
- (PKCollectionParser *)filterExpr {
    //NSLog(@"%s", _cmd);
    if (!filterExpr) {
        self.filterExpr = [PKSequence sequence];
        filterExpr.name = @"filterExpr";
        [filterExpr add:self.primaryExpr];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:self.predicate];
        [filterExpr add:a];
    }
    return filterExpr;
}


#pragma mark -
#pragma mark Left Recursion
// [21] OrExpr ::= AndExpr    | OrExpr 'or' AndExpr    

// orAndExpr ::= 'or' AndExpr
// me: AndExpr orAndExpr*
- (PKCollectionParser *)orExpr {
    //NSLog(@"%s", _cmd);
    if (!orExpr) {
        self.orExpr = [PKSequence sequence];
        orExpr.name = @"orExpr";
        
        [orExpr add:self.andExpr];
        
        PKSequence *orAndExpr = [PKSequence sequence];
        [orAndExpr add:[PKLiteral literalWithString:@"or"]];
        [orAndExpr add:self.andExpr];
        
        [orExpr add:[PKRepetition repetitionWithSubparser:orAndExpr]];
    }
    return orExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [22] AndExpr ::= EqualityExpr | AndExpr 'and' EqualityExpr    


// andEqualityExpr
// EqualityExpr andEqualityExpr

- (PKCollectionParser *)andExpr {
    //NSLog(@"%s", _cmd);
    if (!andExpr) {
        self.andExpr = [PKSequence sequence];
        andExpr.name = @"andExpr";
        [andExpr add:self.equalityExpr];

        PKSequence *andEqualityExpr = [PKSequence sequence];
        [andEqualityExpr add:[PKLiteral literalWithString:@"and"]];
        [andEqualityExpr add:self.equalityExpr];
        
        [andExpr add:[PKRepetition repetitionWithSubparser:andEqualityExpr]];
    }
    return andExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [23] EqualityExpr ::= RelationalExpr    
//            | EqualityExpr '=' RelationalExpr
//            | EqualityExpr '!=' RelationalExpr    

// RelationalExpr (equalsRelationalExpr | notEqualsRelationalExpr)?

- (PKCollectionParser *)equalityExpr {
    //NSLog(@"%s", _cmd);
    if (!equalityExpr) {
        self.equalityExpr = [PKSequence sequence];
        equalityExpr.name = @"equalityExpr";
        [equalityExpr add:self.relationalExpr];
        
        PKSequence *equalsRelationalExpr = [PKSequence sequence];
        [equalsRelationalExpr add:[PKSymbol symbolWithString:@"="]];
        [equalsRelationalExpr add:self.relationalExpr];
        
        PKSequence *notEqualsRelationalExpr = [PKSequence sequence];
        [notEqualsRelationalExpr add:[PKSymbol symbolWithString:@"!="]];
        [notEqualsRelationalExpr add:self.relationalExpr];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:equalsRelationalExpr];
        [a add:notEqualsRelationalExpr];
        
        PKAlternation *a1 = [PKAlternation alternation];
        [a1 add:[PKEmpty empty]];
        [a1 add:a];
        
        [equalityExpr add:a1];
    }
    return equalityExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [24] RelationalExpr ::= AdditiveExpr
//                        | RelationalExpr '<' AdditiveExpr    
//                        | RelationalExpr '>' AdditiveExpr    
//                        | RelationalExpr '<=' AdditiveExpr    
//                        | RelationalExpr '>=' AdditiveExpr

// RelationalExpr = AdditiveExpr (ltAdditiveExpr | gtAdditiveExpr | lteAdditiveExpr | gteAdditiveExpr)?
- (PKCollectionParser *)relationalExpr {
    //NSLog(@"%s", _cmd);
    if (!relationalExpr) {
        
        self.relationalExpr = [PKSequence sequence];
        relationalExpr.name = @"relationalExpr";
        [relationalExpr add:self.additiveExpr];
        
        PKAlternation *a = [PKAlternation alternation];
        
        PKSequence *ltAdditiveExpr = [PKSequence sequence];
        [ltAdditiveExpr add:[PKSymbol symbolWithString:@"<"]];
        [a add:ltAdditiveExpr];

        PKSequence *gtAdditiveExpr = [PKSequence sequence];
        [gtAdditiveExpr add:[PKSymbol symbolWithString:@">"]];
        [a add:gtAdditiveExpr];

        PKSequence *lteAdditiveExpr = [PKSequence sequence];
        [lteAdditiveExpr add:[PKSymbol symbolWithString:@"<="]];
        [a add:lteAdditiveExpr];

        PKSequence *gteAdditiveExpr = [PKSequence sequence];
        [gteAdditiveExpr add:[PKSymbol symbolWithString:@">="]];
        [a add:gteAdditiveExpr];
        
        PKAlternation *a1 = [PKAlternation alternation];
        [a1 add:[PKEmpty empty]];
        [a1 add:a];
        
        [relationalExpr add:a1];
    }
    return relationalExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [25] AdditiveExpr ::= MultiplicativeExpr    
//                        | AdditiveExpr '+' MultiplicativeExpr    
//                        | AdditiveExpr '-' MultiplicativeExpr    

// AdditiveExpr ::= MultiplicativeExpr (plusMultiplicativeExpr | minusMultiplicativeExpr)?
- (PKCollectionParser *)additiveExpr {
    //NSLog(@"%s", _cmd);
    if (!additiveExpr) {
        self.additiveExpr = [PKSequence sequence];
        additiveExpr.name = @"additiveExpr";
        [additiveExpr add:self.multiplicativeExpr];
        
        PKAlternation *a = [PKAlternation alternation];

        PKSequence *plusMultiplicativeExpr = [PKSequence sequence];
        [plusMultiplicativeExpr add:[PKSymbol symbolWithString:@"+"]];
        [plusMultiplicativeExpr add:self.multiplicativeExpr];
        [a add:plusMultiplicativeExpr];
        
        PKSequence *minusMultiplicativeExpr = [PKSequence sequence];
        [minusMultiplicativeExpr add:[PKSymbol symbolWithString:@"-"]];
        [minusMultiplicativeExpr add:self.multiplicativeExpr];
        [a add:minusMultiplicativeExpr];
        
        PKAlternation *a1 = [PKAlternation alternation];
        [a1 add:[PKEmpty empty]];
        [a1 add:a];
        
        [additiveExpr add:a1];
    }
    return additiveExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [26] MultiplicativeExpr ::= UnaryExpr    
//                            | MultiplicativeExpr MultiplyOperator UnaryExpr    
//                            | MultiplicativeExpr 'div' UnaryExpr    
//                            | MultiplicativeExpr 'mod' UnaryExpr

// MultiplicativeExpr :: = UnaryExpr (multiplyUnaryExpr | divUnaryExpr | modUnaryExpr)? 
- (PKCollectionParser *)multiplicativeExpr {
    //NSLog(@"%s", _cmd);
    if (!multiplicativeExpr) {
        self.multiplicativeExpr = [PKSequence sequence];
        multiplicativeExpr.name = @"multiplicativeExpr";
        [multiplicativeExpr add:self.unaryExpr];
        
        PKAlternation *a = [PKAlternation alternation];
        
        PKSequence *multiplyUnaryExpr = [PKSequence sequence];
        [multiplyUnaryExpr add:self.multiplyOperator];
        [multiplyUnaryExpr add:self.unaryExpr];
        [a add:multiplyUnaryExpr];
        
        PKSequence *divUnaryExpr = [PKSequence sequence];
        [divUnaryExpr add:[PKLiteral literalWithString:@"div"]];
        [divUnaryExpr add:self.unaryExpr];
        [a add:divUnaryExpr];
        
        PKSequence *modUnaryExpr = [PKSequence sequence];
        [modUnaryExpr add:[PKLiteral literalWithString:@"mod"]];
        [modUnaryExpr add:self.unaryExpr];
        [a add:modUnaryExpr];
        
        PKAlternation *a1 = [PKAlternation alternation];
        [a1 add:[PKEmpty empty]];
        [a1 add:a];
        
        [multiplicativeExpr add:a1];
    }
    return multiplicativeExpr;
}


#pragma mark -
#pragma mark Left Recursion

// [27] UnaryExpr ::= UnionExpr | '-' UnaryExpr

// UnaryExpr ::= '-'? UnionExpr
- (PKCollectionParser *)unaryExpr {
    //NSLog(@"%s", _cmd);
    if (!unaryExpr) {
        self.unaryExpr = [PKSequence sequence];
        unaryExpr.name = @"unaryExpr";
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKEmpty empty]];
        [a add:[PKSymbol symbolWithString:@"-"]];
        
        [unaryExpr add:a];
        [unaryExpr add:self.unionExpr];
        
        //        self.unaryExpr = [PKAlternation alternation];
//        [unaryExpr add:self.unionExpr];
//        
//        PKSequence *s = [PKSequence sequence];
//        [s add:[PKSymbol symbolWithString:@"-"]];
//        [s add:unaryExpr];
//        [unionExpr add:s];
    }
    return unaryExpr;
}


// [28] ExprToken ::= '(' | ')' | '[' | ']' | '.' | '..' | '@' | ',' | '::'
//                    | NameTest    
//                    | NodeType    
//                    | Operator    
//                    | FunctionName    
//                    | AxisName    
//                    | Literal    
//                    | Number    
//                    | VariableReference    
- (PKCollectionParser *)exprToken {
    //NSLog(@"%s", _cmd);
    if (!exprToken) {
        self.exprToken = [PKAlternation alternation];
        exprToken.name = @"exprToken";
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:[PKSymbol symbolWithString:@"("]];
        [a add:[PKSymbol symbolWithString:@")"]];
        [a add:[PKSymbol symbolWithString:@"["]];
        [a add:[PKSymbol symbolWithString:@"]"]];
        [a add:[PKSymbol symbolWithString:@"."]];
        [a add:[PKSymbol symbolWithString:@".."]];
        [a add:[PKSymbol symbolWithString:@"@"]];
        [a add:[PKSymbol symbolWithString:@","]];
        [a add:[PKSymbol symbolWithString:@"::"]];
        [exprToken add:a];
        
        [exprToken add:self.nameTest];
        [exprToken add:self.nodeType];
        [exprToken add:self.operator];
        [exprToken add:self.functionName];
        [exprToken add:self.axisName];
        [exprToken add:self.literal];
        [exprToken add:self.number];
        [exprToken add:self.variableReference];
    }
    return exprToken;
}


- (PKParser *)literal {
    //NSLog(@"%s", _cmd);
    if (!literal) {
        self.literal = [PKQuotedString quotedString];
        literal.name = @"literal";
    }
    return literal;
}


- (PKParser *)number {
    //NSLog(@"%s", _cmd);
    if (!number) {
        self.number = [PKNumber number];
        number.name = @"number";
    }
    return number;
}


// [32] Operator ::= OperatorName    
//                    | MultiplyOperator    
//                    | '/' | '//' | '|' | '+' | '-' | '=' | '!=' | '<' | '<=' | '>' | '>='    
- (PKCollectionParser *)operator {
    //NSLog(@"%s", _cmd);
    if (!operator) {
        self.operator = [PKAlternation alternation];
        operator.name = @"operator";
        [operator add:self.operatorName];
        [operator add:self.multiplyOperator];
        [operator add:[PKSymbol symbolWithString: @"/"]];
        [operator add:[PKSymbol symbolWithString:@"//"]];
        [operator add:[PKSymbol symbolWithString: @"|"]];
        [operator add:[PKSymbol symbolWithString: @"+"]];
        [operator add:[PKSymbol symbolWithString: @"-"]];
        [operator add:[PKSymbol symbolWithString: @"="]];
        [operator add:[PKSymbol symbolWithString:@"!="]];
        [operator add:[PKSymbol symbolWithString: @"<"]];
        [operator add:[PKSymbol symbolWithString:@"<="]];
        [operator add:[PKSymbol symbolWithString: @">"]];
        [operator add:[PKSymbol symbolWithString:@">="]];
    }
    return operator;
}


// [33] OperatorName ::=       'and' | 'or' | 'mod' | 'div'    
- (PKCollectionParser *)operatorName {
    //NSLog(@"%s", _cmd);
    if (!operatorName) {
        self.operatorName = [PKAlternation alternation];
        operatorName.name = @"operatorName";
        [operatorName add:[PKLiteral literalWithString:@"and"]];
        [operatorName add:[PKLiteral literalWithString: @"or"]];
        [operatorName add:[PKLiteral literalWithString:@"mod"]];
        [operatorName add:[PKLiteral literalWithString:@"div"]];
    }
    return operatorName;
}


// [34]       MultiplyOperator                    ::=       '*'    
- (PKParser *)multiplyOperator {
    //NSLog(@"%s", _cmd);
    if (!multiplyOperator) {
        self.multiplyOperator = [PKSymbol symbolWithString:@"*"];
        multiplyOperator.name = @"multiplyOperator";
    }
    return multiplyOperator;
}


//[7]       QName       ::=   PrefixedName| UnprefixedName
//[8]       PrefixedName ::=        Prefix ':' LocalPart
//[9]       UnprefixedName     ::=        LocalPart
//[10]       Prefix       ::=       NCName
//[11]       LocalPart       ::=       NCName
- (PKCollectionParser *)QName {
    //NSLog(@"%s", _cmd);
    if (!QName) {
        self.QName = [PKAlternation alternation];
        QName.name = @"QName";

        PKParser *prefix = [PKWord word];
        PKParser *localPart = [PKWord word];
        PKParser *unprefixedName = localPart;
        
        PKSequence *prefixedName = [PKSequence sequence];
        [prefixedName add:prefix];
        [prefixedName add:[PKSymbol symbolWithString:@":"]];
        [prefixedName add:localPart];
        
        [QName add:prefixedName];
        [QName add:unprefixedName];
    }
    return QName;
}


// [35] FunctionName ::= QName - NodeType    
- (PKParser *)functionName {
    //NSLog(@"%s", _cmd);
    if (!functionName) {
        self.functionName = self.QName; // TODO QName - NodeType
        functionName.name = @"functionName";
    }
    return functionName;
}


// [36]  VariableReference ::=       '$' QName    
- (PKCollectionParser *)variableReference {
    //NSLog(@"%s", _cmd);
    if (!variableReference) {
        self.variableReference = [PKSequence sequence];
        variableReference.name = @"variableReference";
        [variableReference add:[PKSymbol symbolWithString:@"$"]];
        [variableReference add:self.QName];
    }
    return variableReference;
}


// [37] NameTest ::= '*' | NCName ':' '*' | QName    
- (PKCollectionParser *)nameTest {
    //NSLog(@"%s", _cmd);
    if (!nameTest) {
        self.nameTest = [PKAlternation alternation];
        nameTest.name = @"nameTest";
        [nameTest add:[PKSymbol symbolWithString:@"*"]];

        PKSequence *s = [PKSequence sequence];
        [s add:[PKWord word]];
        [s add:[PKSymbol symbolWithString:@":"]];
        [s add:[PKSymbol symbolWithString:@"*"]];
        [nameTest add:s];
        
        [nameTest add:self.QName];
    }
    return nameTest;
}


// [38] NodeType ::= 'comment'    
//                    | 'text'    
//                    | 'processing-instruction'    
//                    | 'node'
- (PKCollectionParser *)nodeType {
    //NSLog(@"%s", _cmd);
    if (!nodeType) {
        self.nodeType = [PKAlternation alternation];
        nodeType.name = @"nodeType";
        [nodeType add:[PKLiteral literalWithString:@"comment"]];
        [nodeType add:[PKLiteral literalWithString:@"text"]];
        [nodeType add:[PKLiteral literalWithString:@"processing-instruction"]];
        [nodeType add:[PKLiteral literalWithString:@"node"]];
    }
    return nodeType;
}

@synthesize xpathAssembler;
@synthesize locationPath;
@synthesize absoluteLocationPath;
@synthesize relativeLocationPath;
@synthesize step;
@synthesize axisSpecifier;
@synthesize axisName;
@synthesize nodeTest;
@synthesize predicate;
@synthesize predicateExpr;
@synthesize abbreviatedAbsoluteLocationPath;
@synthesize abbreviatedRelativeLocationPath;
@synthesize abbreviatedStep;
@synthesize abbreviatedAxisSpecifier;
@synthesize expr;
@synthesize primaryExpr;
@synthesize functionCall;
@synthesize argument;
@synthesize unionExpr;
@synthesize pathExpr;
@synthesize filterExpr;
@synthesize orExpr;
@synthesize andExpr;
@synthesize equalityExpr;
@synthesize relationalExpr;
@synthesize additiveExpr;
@synthesize multiplicativeExpr;
@synthesize unaryExpr;
@synthesize exprToken;
@synthesize literal;
@synthesize number;
@synthesize operator;
@synthesize operatorName;
@synthesize multiplyOperator;
@synthesize functionName;
@synthesize variableReference;
@synthesize nameTest;
@synthesize nodeType;
@synthesize QName;
@end
