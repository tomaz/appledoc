//
//  PKJavaScriptParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJavaScriptParser.h"

@interface PKParser ()
- (void)setTokenizer:(PKTokenizer *)t;
@end

@interface TDJavaScriptParser ()
- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;
@end

@implementation TDJavaScriptParser

- (id)init {
    if (self = [super initWithSubparser:self.elementParser]) {
        self.tokenizer = [PKTokenizer tokenizer];
        
        // JS supports scientific number notation (exponents like 4E+12 or 2.0e-42)
        tokenizer.numberState.allowsScientificNotation = YES;

        // Nums cannot end with '.' (e.g. 32. must be 32.0)
        tokenizer.numberState.allowsTrailingDot = NO;
        
        [tokenizer setTokenizerState:tokenizer.numberState from:'-' to:'-'];
        [tokenizer setTokenizerState:tokenizer.numberState from:'.' to:'.'];
        [tokenizer setTokenizerState:tokenizer.numberState from:'0' to:'9'];

        // Words can start with '_'
        [tokenizer setTokenizerState:tokenizer.wordState from:'_' to:'_'];

        // Words cannot contain '-'
        [tokenizer.wordState setWordChars:NO from:'-' to:'-'];

        // Comments
        tokenizer.commentState.reportsCommentTokens = YES;
        [tokenizer setTokenizerState:tokenizer.commentState from:'/' to:'/'];

        // single-line Comments
        [tokenizer.commentState addSingleLineStartMarker:@"//"];
        
        // multi-line Comments
        [tokenizer.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
        
        [tokenizer.symbolState add:@"||"];
        [tokenizer.symbolState add:@"&&"];
        [tokenizer.symbolState add:@"!="];
        [tokenizer.symbolState add:@"!=="];
        [tokenizer.symbolState add:@"=="];
        [tokenizer.symbolState add:@"==="];
        [tokenizer.symbolState add:@"<="];
        [tokenizer.symbolState add:@">="];
        [tokenizer.symbolState add:@"++"];
        [tokenizer.symbolState add:@"--"];
        [tokenizer.symbolState add:@"+="];
        [tokenizer.symbolState add:@"-="];
        [tokenizer.symbolState add:@"*="];
        [tokenizer.symbolState add:@"/="];
        [tokenizer.symbolState add:@"%="];
        [tokenizer.symbolState add:@"<<"];
        [tokenizer.symbolState add:@">>"];
        [tokenizer.symbolState add:@">>>"];
        [tokenizer.symbolState add:@"<<="];
        [tokenizer.symbolState add:@">>="];
        [tokenizer.symbolState add:@">>>="];
        [tokenizer.symbolState add:@"&="];
        [tokenizer.symbolState add:@"^="];
    }
    return self;
}


- (void)dealloc {    
    self.assignmentOpParser = nil;
    self.relationalOpParser = nil;
    self.equalityOpParser = nil;
    self.shiftOpParser = nil;
    self.incrementOpParser = nil;
    self.unaryOpParser = nil;
    self.multiplicativeOpParser = nil;
    self.programParser = nil;
    self.elementParser = nil;
    self.funcParser = nil;
    self.paramListOptParser = nil;
    self.paramListParser = nil;
    self.commaIdentifierParser = nil;
    self.compoundStmtParser = nil;
    self.stmtsParser = nil;
    self.stmtParser = nil;
    self.ifStmtParser = nil;
    self.ifElseStmtParser = nil;
    self.whileStmtParser = nil;
    self.forParenStmtParser = nil;
    self.forBeginStmtParser = nil;
    self.forInStmtParser = nil;
    self.breakStmtParser = nil;
    self.continueStmtParser = nil;
    self.withStmtParser = nil;
    self.returnStmtParser = nil;
    self.variablesOrExprStmtParser = nil;
    self.conditionParser = nil;
    self.forParenParser = nil;
    self.forBeginParser = nil;
    self.variablesOrExprParser = nil;
    self.varVariablesParser = nil;
    self.variablesParser = nil;
    self.commaVariableParser = nil;
    self.variableParser = nil;
    self.assignmentParser = nil;
    self.exprOptParser = nil;
    self.exprParser = nil;
    self.commaAssignmentExprParser = nil;
    self.assignmentExprParser = nil;
    self.assignmentOpConditionalExprParser = nil;
    self.conditionalExprParser = nil;
    self.ternaryExprParser = nil;
    self.orExprParser = nil;
    self.orAndExprParser = nil;
    self.andExprParser = nil;
    self.andBitwiseOrExprParser = nil;
    self.bitwiseOrExprParser = nil;
    self.pipeBitwiseXorExprParser = nil;
    self.bitwiseXorExprParser = nil;
    self.caretBitwiseAndExprParser = nil;
    self.bitwiseAndExprParser = nil;
    self.ampEqualityExprParser = nil;
    self.equalityExprParser = nil;
    self.equalityOpRelationalExprParser = nil;
    self.relationalExprParser = nil;
    self.relationalOpShiftExprParser = nil;
    self.shiftExprParser = nil;
    self.shiftOpAdditiveExprParser = nil;
    self.additiveExprParser = nil;
    self.plusOrMinusExprParser = nil;
    self.plusExprParser = nil;
    self.minusExprParser = nil;
    self.multiplicativeExprParser = nil;
    self.multiplicativeOpUnaryExprParser = nil;
    self.unaryExprParser = nil;
    self.unaryExpr1Parser = nil;
    self.unaryExpr2Parser = nil;
    self.unaryExpr3Parser = nil;
    self.unaryExpr4Parser = nil;
    self.unaryExpr5Parser = nil;
    self.unaryExpr6Parser = nil;
    self.constructorCallParser = nil;
    self.parenArgListOptParenParser = nil;
    self.memberExprParser = nil;
    self.memberExprExtParser = nil;
    self.dotMemberExprParser = nil;
    self.bracketMemberExprParser = nil;
    self.argListOptParser = nil;
    self.argListParser = nil;
    self.primaryExprParser = nil;
    self.parenExprParenParser = nil;

    self.funcLiteralParser = nil;
    self.arrayLiteralParser = nil;
    self.objectLiteralParser = nil;

    self.identifierParser = nil;
    self.stringParser = nil;
    self.numberParser = nil;

    self.ifParser = nil;
    self.elseParser = nil;
    self.whileParser = nil;
    self.forParser = nil;
    self.inParser = nil;
    self.breakParser = nil;
    self.continueParser = nil;
    self.withParser = nil;
    self.returnParser = nil;
    self.varParser = nil;
    self.deleteParser = nil;
    self.newParser = nil;
    self.thisParser = nil;
    self.falseParser = nil;
    self.trueParser = nil;
    self.nullParser = nil;
    self.undefinedParser = nil;
    self.voidParser = nil;
    self.typeofParser = nil;
    self.instanceofParser = nil;
    self.functionParser = nil;
    
    self.orParser = nil;
    self.andParser = nil;
    self.neParser = nil;
    self.isNotParser = nil;
    self.eqParser = nil;
    self.isParser = nil;
    self.leParser = nil;
    self.geParser = nil;
    self.plusPlusParser = nil;
    self.minusMinusParser = nil;
    self.plusEqParser = nil;
    self.minusEqParser = nil;
    self.timesEqParser = nil;
    self.divEqParser = nil;
    self.modEqParser = nil;
    self.shiftLeftParser = nil;
    self.shiftRightParser = nil;
    self.shiftRightExtParser = nil;
    self.shiftLeftEqParser = nil;
    self.shiftRightEqParser = nil;
    self.shiftRightExtEqParser = nil;
    self.andEqParser = nil;
    self.xorEqParser = nil;
    self.orEqParser = nil;
    
    self.openCurlyParser = nil;
    self.closeCurlyParser = nil;
    self.openParenParser = nil;
    self.closeParenParser = nil;
    self.openBracketParser = nil;
    self.closeBracketParser = nil;
    self.commaParser = nil;
    self.dotParser = nil;
    self.semiOptParser = nil;
    self.semiParser = nil;
    self.colonParser = nil;
    self.equalsParser = nil;
    self.notParser = nil;
    self.ltParser = nil;
    self.gtParser = nil;
    self.ampParser = nil;
    self.pipeParser = nil;
    self.caretParser = nil;
    self.tildeParser = nil;
    self.questionParser = nil;
    self.plusParser = nil;
    self.minusParser = nil;
    self.timesParser = nil;
    self.divParser = nil;
    self.modParser = nil;

    [super dealloc];
}


- (PKAlternation *)zeroOrOne:(PKParser *)p {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[PKEmpty empty]];
    [a add:p];
    return a;
}


- (PKSequence *)oneOrMore:(PKParser *)p {
    PKSequence *s = [PKSequence sequence];
    [s add:p];
    [s add:[PKRepetition repetitionWithSubparser:p]];
    return s;
}


// assignmentOperator  = equals | plusEq | minusEq | timesEq | divEq | modEq | shiftLeftEq | shiftRightEq | shiftRightExtEq | andEq | xorEq | orEq;
- (PKCollectionParser *)assignmentOpParser {
    if (!assignmentOpParser) {
        self.assignmentOpParser = [PKAlternation alternation];
        assignmentOpParser.name = @"assignmentOp";
        [assignmentOpParser add:self.equalsParser];
        [assignmentOpParser add:self.plusEqParser];
        [assignmentOpParser add:self.minusEqParser];
        [assignmentOpParser add:self.timesEqParser];
        [assignmentOpParser add:self.divEqParser];
        [assignmentOpParser add:self.modEqParser];
        [assignmentOpParser add:self.shiftLeftEqParser];
        [assignmentOpParser add:self.shiftRightEqParser];
        [assignmentOpParser add:self.shiftRightExtEqParser];
        [assignmentOpParser add:self.andEqParser];
        [assignmentOpParser add:self.orEqParser];
        [assignmentOpParser add:self.xorEqParser];
    }
    return assignmentOpParser;
}


// relationalOperator  = lt | gt | ge | le | instanceof;
- (PKCollectionParser *)relationalOpParser {
    if (!relationalOpParser) {
        self.relationalOpParser = [PKAlternation alternation];
        relationalOpParser.name = @"relationalOp";
        [relationalOpParser add:self.ltParser];
        [relationalOpParser add:self.gtParser];
        [relationalOpParser add:self.geParser];
        [relationalOpParser add:self.leParser];
        [relationalOpParser add:self.instanceofParser];
    }
    return relationalOpParser;
}


// equalityOp    = eq | ne | is | isnot;
- (PKCollectionParser *)equalityOpParser {
    if (!equalityOpParser) {
        self.equalityOpParser = [PKAlternation alternation];;
        equalityOpParser.name = @"equalityOp";
        [equalityOpParser add:self.eqParser];
        [equalityOpParser add:self.neParser];
        [equalityOpParser add:self.isParser];
        [equalityOpParser add:self.isNotParser];
    }
    return equalityOpParser;
}


//shiftOp         = shiftLeft | shiftRight | shiftRightExt;
- (PKCollectionParser *)shiftOpParser {
    if (!shiftOpParser) {
        self.shiftOpParser = [PKAlternation alternation];
        shiftOpParser.name = @"shiftOp";
        [shiftOpParser add:self.shiftLeftParser];
        [shiftOpParser add:self.shiftRightParser];
        [shiftOpParser add:self.shiftRightExtParser];
    }
    return shiftOpParser;
}


//incrementOperator   = plusPlus | minusMinus;
- (PKCollectionParser *)incrementOpParser {
    if (!incrementOpParser) {
        self.incrementOpParser = [PKAlternation alternation];
        incrementOpParser.name = @"incrementOp";
        [incrementOpParser add:self.plusPlusParser];
        [incrementOpParser add:self.minusMinusParser];
    }
    return incrementOpParser;
}


//unaryOperator       = tilde | delete | typeof | void;
- (PKCollectionParser *)unaryOpParser {
    if (!unaryOpParser) {
        self.unaryOpParser = [PKAlternation alternation];
        unaryOpParser.name = @"unaryOp";
        [unaryOpParser add:self.tildeParser];
        [unaryOpParser add:self.deleteParser];
        [unaryOpParser add:self.typeofParser];
        [unaryOpParser add:self.voidParser];
    }
    return unaryOpParser;
}


// multiplicativeOperator = times | div | mod;
- (PKCollectionParser *)multiplicativeOpParser {
    if (!multiplicativeOpParser) {
        self.multiplicativeOpParser = [PKAlternation alternation];
        multiplicativeOpParser.name = @"multiplicativeOperator";
        [multiplicativeOpParser add:self.timesParser];
        [multiplicativeOpParser add:self.divParser];
        [multiplicativeOpParser add:self.modParser];
    }
    return multiplicativeOpParser;
}



// Program:
//           empty
//           Element Program
//
//program             = element*;
- (PKCollectionParser *)programParser {
    if (!programParser) {
        self.programParser = [PKRepetition repetitionWithSubparser:self.elementParser];
        programParser.name = @"program";
    }
    return programParser;
}


//  Element:
//           function Identifier ( ParameterListOpt ) CompoundStatement
//           Statement
//
//element             = func | stmt;
- (PKCollectionParser *)elementParser {
    if (!elementParser) {
        self.elementParser = [PKAlternation alternation];
        elementParser.name = @"element";
        [elementParser add:self.funcParser];
        [elementParser add:self.stmtParser];
    }
    return elementParser;
}


//func                = function identifier openParen paramListOpt closeParen compoundStmt;
- (PKCollectionParser *)funcParser {
    if (!funcParser) {
        self.funcParser = [PKSequence sequence];
        funcParser.name = @"func";
        [funcParser add:self.functionParser];
        [funcParser add:self.identifierParser];
        [funcParser add:self.openParenParser];
        [funcParser add:self.paramListOptParser];
        [funcParser add:self.closeParenParser];
        [funcParser add:self.compoundStmtParser];
    }
    return funcParser;
}


//  ParameterListOpt:
//           empty
//           ParameterList
//
//paramListOpt        = Empty | paramList;
- (PKCollectionParser *)paramListOptParser {
    if (!paramListOptParser) {
        self.paramListOptParser = [PKAlternation alternation];
        paramListOptParser.name = @"paramListOpt";
        [paramListOptParser add:[self zeroOrOne:self.paramListParser]];
    }
    return paramListOptParser;
}


//  ParameterList:
//           Identifier
//           Identifier , ParameterList
//
//paramList           = identifier commaIdentifier*;
- (PKCollectionParser *)paramListParser {
    if (!paramListParser) {
        self.paramListParser = [PKSequence sequence];
        paramListParser.name = @"paramList";
        [paramListParser add:self.identifierParser];
        [paramListParser add:[PKRepetition repetitionWithSubparser:self.commaIdentifierParser]];
    }
    return paramListParser;
}


//commaIdentifier     = comma identifier;
- (PKCollectionParser *)commaIdentifierParser {
    if (!commaIdentifierParser) {
        self.commaIdentifierParser = [PKSequence sequence];
        commaIdentifierParser.name = @"commaIdentifier";
        [commaIdentifierParser add:self.commaParser];
        [commaIdentifierParser add:self.identifierParser];
    }
    return commaIdentifierParser;
}


//  CompoundStatement:
//           { Statements }
//
//compoundStmt        = openCurly stmts closeCurly;
- (PKCollectionParser *)compoundStmtParser {
    if (!compoundStmtParser) {
        self.compoundStmtParser = [PKSequence sequence];
        compoundStmtParser.name = @"compoundStmt";
        [compoundStmtParser add:self.openCurlyParser];
        [compoundStmtParser add:self.stmtsParser];
        [compoundStmtParser add:self.closeCurlyParser];
    }
    return compoundStmtParser;
}


//  Statements:
//           empty
//           Statement Statements
//
//stmts               = stmt*;
- (PKCollectionParser *)stmtsParser {
    if (!stmtsParser) {
        self.stmtsParser = [PKRepetition repetitionWithSubparser:self.stmtParser];
        stmtsParser.name = @"stmts";
    }
    return stmtsParser;
}


//  Statement:
//           ;
//           if Condition Statement
//           if Condition Statement else Statement
//           while Condition Statement
//           ForParen ; ExpressionOpt ; ExpressionOpt ) Statement
//           ForBegin ; ExpressionOpt ; ExpressionOpt ) Statement
//           ForBegin in Expression ) Statement
//           break ;
//           continue ;
//           with ( Expression ) Statement
//           return ExpressionOpt ;
//           CompoundStatement
//           VariablesOrExpression ;
//
//stmt                = semi | ifStmt | ifElseStmt | whileStmt | forParenStmt | forBeginStmt | forInStmt | breakStmt | continueStmt | withStmt | returnStmt | compoundStmt | variablesOrExprStmt;
- (PKCollectionParser *)stmtParser {
    if (!stmtParser) {
        self.stmtParser = [PKAlternation alternation];
        stmtParser.name = @"stmt";
        [stmtParser add:self.semiParser];
        [stmtParser add:self.ifStmtParser];
        [stmtParser add:self.ifElseStmtParser];
        [stmtParser add:self.whileStmtParser];
        [stmtParser add:self.forParenStmtParser];
        [stmtParser add:self.forBeginStmtParser];
        [stmtParser add:self.forInStmtParser];
        [stmtParser add:self.breakStmtParser];
        [stmtParser add:self.continueStmtParser];
        [stmtParser add:self.withStmtParser];
        [stmtParser add:self.returnStmtParser];
        [stmtParser add:self.compoundStmtParser];
        [stmtParser add:self.variablesOrExprStmtParser];        
    }
    return stmtParser;
}


//           if Condition Statement
//ifStmt              = if condition stmt;
- (PKCollectionParser *)ifStmtParser {
    if (!ifStmtParser) {
        self.ifStmtParser = [PKSequence sequence];
        ifStmtParser.name = @"ifStmt";
        [ifStmtParser add:self.ifParser];
        [ifStmtParser add:self.conditionParser];
        [ifStmtParser add:self.stmtParser];
    }
    return ifStmtParser;
}


//           if Condition Statement else Statement
//ifElseStmt          = if condition stmt else stmt;
- (PKCollectionParser *)ifElseStmtParser {
    if (!ifElseStmtParser) {
        self.ifElseStmtParser = [PKSequence sequence];
        ifElseStmtParser.name = @"ifElseStmt";
        [ifElseStmtParser add:self.ifParser];
        [ifElseStmtParser add:self.conditionParser];
        [ifElseStmtParser add:self.stmtParser];
        [ifElseStmtParser add:self.elseParser];
        [ifElseStmtParser add:self.stmtParser];
    }
    return ifElseStmtParser;
}


//           while Condition Statement
//whileStmt           = while condition stmt;
- (PKCollectionParser *)whileStmtParser {
    if (!whileStmtParser) {
        self.whileStmtParser = [PKSequence sequence];
        whileStmtParser.name = @"whileStmt";
        [whileStmtParser add:self.whileParser];
        [whileStmtParser add:self.conditionParser];
        [whileStmtParser add:self.stmtParser];
    }
    return whileStmtParser;
}


//           ForParen ; ExpressionOpt ; ExpressionOpt ) Statement
//forParenStmt        = forParen semi exprOpt semi exprOpt closeParen stmt;
- (PKCollectionParser *)forParenStmtParser {
    if (!forParenStmtParser) {
        self.forParenStmtParser = [PKSequence sequence];
        forParenStmtParser.name = @"forParenStmt";
        [forParenStmtParser add:self.forParenParser];
        [forParenStmtParser add:self.semiParser];
        [forParenStmtParser add:self.exprOptParser];
        [forParenStmtParser add:self.semiParser];
        [forParenStmtParser add:self.exprOptParser];
        [forParenStmtParser add:self.closeParenParser];
        [forParenStmtParser add:self.stmtParser];
    }
    return forParenStmtParser;
}


//           ForBegin ; ExpressionOpt ; ExpressionOpt ) Statement
//forBeginStmt        = forBegin semi exprOpt semi exprOpt closeParen stmt;
- (PKCollectionParser *)forBeginStmtParser {
    if (!forBeginStmtParser) {
        self.forBeginStmtParser = [PKSequence sequence];
        forBeginStmtParser.name = @"forBeginStmt";
        [forBeginStmtParser add:self.forBeginParser];
        [forBeginStmtParser add:self.semiParser];
        [forBeginStmtParser add:self.exprOptParser];
        [forBeginStmtParser add:self.semiParser];
        [forBeginStmtParser add:self.exprOptParser];
        [forBeginStmtParser add:self.closeParenParser];
        [forBeginStmtParser add:self.stmtParser];
    }
    return forBeginStmtParser;
}


//           ForBegin in Expression ) Statement
//forInStmt           = forBegin in expr closeParen stmt;
- (PKCollectionParser *)forInStmtParser {
    if (!forInStmtParser) {
        self.forInStmtParser = [PKSequence sequence];
        forInStmtParser.name = @"forInStmt";
        [forInStmtParser add:self.forBeginParser];
        [forInStmtParser add:self.inParser];
        [forInStmtParser add:self.exprParser];
        [forInStmtParser add:self.closeParenParser];
        [forInStmtParser add:self.stmtParser];
    }
    return forInStmtParser;
}


//           break ;
//breakStmt           = break semi;
- (PKCollectionParser *)breakStmtParser {
    if (!breakStmtParser) {
        self.breakStmtParser = [PKSequence sequence];
        breakStmtParser.name = @"breakStmt";
        [breakStmtParser add:self.breakParser];
        [breakStmtParser add:self.semiOptParser];
    }
    return breakStmtParser;
}


//continueStmt        = continue semi;
- (PKCollectionParser *)continueStmtParser {
    if (!continueStmtParser) {
        self.continueStmtParser = [PKSequence sequence];
        continueStmtParser.name = @"continueStmt";
        [continueStmtParser add:self.continueParser];
        [continueStmtParser add:self.semiOptParser];
    }
    return continueStmtParser;
}


//           with ( Expression ) Statement
//withStmt            = with openParen expr closeParen stmt;
- (PKCollectionParser *)withStmtParser {
    if (!withStmtParser) {
        self.withStmtParser = [PKSequence sequence];
        withStmtParser.name = @"withStmt";
        [withStmtParser add:self.withParser];
        [withStmtParser add:self.openParenParser];
        [withStmtParser add:self.exprParser];
        [withStmtParser add:self.closeParenParser];
        [withStmtParser add:self.stmtParser];
    }
    return withStmtParser;
}


//           return ExpressionOpt ;
//returnStmt          = return exprOpt semi;
- (PKCollectionParser *)returnStmtParser {
    if (!returnStmtParser) {
        self.returnStmtParser = [PKSequence sequence];
        returnStmtParser.name = @"returnStmt";
        [returnStmtParser add:self.returnParser];
        [returnStmtParser add:self.exprOptParser];
        [returnStmtParser add:self.semiOptParser];
    }
    return returnStmtParser;
}


//           VariablesOrExpression ;
//variablesOrExprStmt = variablesOrExpr semi;
- (PKCollectionParser *)variablesOrExprStmtParser {
    if (!variablesOrExprStmtParser) {
        self.variablesOrExprStmtParser = [PKSequence sequence];
        variablesOrExprStmtParser.name = @"variablesOrExprStmt";
        [variablesOrExprStmtParser add:self.variablesOrExprParser];
        [variablesOrExprStmtParser add:self.semiOptParser];
    }
    return variablesOrExprStmtParser;
}


//  Condition:
//           ( Expression )
//
//condition           = openParen expr closeParen;
- (PKCollectionParser *)conditionParser {
    if (!conditionParser) {
        self.conditionParser = [PKSequence sequence];
        conditionParser.name = @"condition";
        [conditionParser add:self.openParenParser];
        [conditionParser add:self.exprParser];
        [conditionParser add:self.closeParenParser];
    }
    return conditionParser;
}


//  ForParen:
//           for (
//
//forParen            = for openParen;
- (PKCollectionParser *)forParenParser {
    if (!forParenParser) {
        self.forParenParser = [PKSequence sequence];
        forParenParser.name = @"forParen";
        [forParenParser add:self.forParser];
        [forParenParser add:self.openParenParser];
    }
    return forParenParser;
}


//  ForBegin:
//           ForParen VariablesOrExpression
//
//forBegin            = forParen variablesOrExpr;
- (PKCollectionParser *)forBeginParser {
    if (!forBeginParser) {
        self.forBeginParser = [PKSequence sequence];
        forBeginParser.name = @"forBegin";
        [forBeginParser add:self.forParenParser];
        [forBeginParser add:self.variablesOrExprParser];
    }
    return forBeginParser;
}


//  VariablesOrExpression:
//           var Variables
//           Expression
//
//variablesOrExpr     = varVariables | expr;
- (PKCollectionParser *)variablesOrExprParser {
    if (!variablesOrExprParser) {
        self.variablesOrExprParser = [PKAlternation alternation];
        variablesOrExprParser.name = @"variablesOrExpr";
        [variablesOrExprParser add:self.varVariablesParser];
        [variablesOrExprParser add:self.exprParser];
    }
    return variablesOrExprParser;
}


//varVariables        = var variables;
- (PKCollectionParser *)varVariablesParser {
    if (!varVariablesParser) {
        self.varVariablesParser = [PKSequence sequence];
        varVariablesParser.name = @"varVariables";
        [varVariablesParser add:self.varParser];
        [varVariablesParser add:self.variablesParser];
    }
    return varVariablesParser;
}


//  Variables:
//           Variable
//           Variable , Variables
//
//variables           = variable commaVariable*;
- (PKCollectionParser *)variablesParser {
    if (!variablesParser) {
        self.variablesParser = [PKSequence sequence];
        variablesParser.name = @"variables";
        [variablesParser add:self.variableParser];
        [variablesParser add:[PKRepetition repetitionWithSubparser:self.commaVariableParser]];
    }
    return variablesParser;
}


//commaVariable       = comma variable;
- (PKCollectionParser *)commaVariableParser {
    if (!commaVariableParser) {
        self.commaVariableParser = [PKSequence sequence];
        commaVariableParser.name = @"commaVariable";
        [commaVariableParser add:self.commaParser];
        [commaVariableParser add:self.variableParser];
    }
    return commaVariableParser;
}


//  Variable:
//           Identifier
//           Identifier = AssignmentExpression
//
//variable            = identifier assignment?;
- (PKCollectionParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [PKSequence sequence];
        variableParser.name = @"variableParser";
        [variableParser add:self.identifierParser];
        [variableParser add:[self zeroOrOne:self.assignmentParser]];
    }
    return variableParser;
}


//assignment          = equals assignmentExpr;
- (PKCollectionParser *)assignmentParser {
    if (!assignmentParser) {
        self.assignmentParser = [PKSequence sequence];
        assignmentParser.name = @"assignment";
        [assignmentParser add:self.equalsParser];
        [assignmentParser add:self.assignmentExprParser];
    }
    return assignmentParser;
}


//  ExpressionOpt:
//           empty
//           Expression
//
//    exprOpt             = Empty | expr;
- (PKCollectionParser *)exprOptParser {
    if (!exprOptParser) {
        self.exprOptParser = [self zeroOrOne:self.exprParser];
        exprOptParser.name = @"exprOpt";
    }
    return exprOptParser;
}


//  Expression:
//           AssignmentExpression
//           AssignmentExpression , Expression
//
//expr                = assignmentExpr commaAssignmentExpr*;
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        exprParser.name = @"exprParser";
        [exprParser add:self.assignmentExprParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.commaAssignmentExprParser]];
    }
    return exprParser;
}


//commaAssignmentExpr           = comma assignmentExpr;
- (PKCollectionParser *)commaAssignmentExprParser {
    if (!commaAssignmentExprParser) {
        self.commaAssignmentExprParser = [PKSequence sequence];
        commaAssignmentExprParser.name = @"commaAssignmentExpr";
        [commaAssignmentExprParser add:self.commaParser];
        [commaAssignmentExprParser add:self.assignmentExprParser];
    }
    return commaAssignmentExprParser;
}


//  AssignmentExpression:
//           ConditionalExpression
//           ConditionalExpression AssignmentOperator AssignmentExpression
//
// assignmentExpr      = conditionalExpr assignmentOpConditionalExpr*;
- (PKCollectionParser *)assignmentExprParser {
    if (!assignmentExprParser) {
        self.assignmentExprParser = [PKSequence sequence];
        assignmentExprParser.name = @"assignmentExpr";
        [assignmentExprParser add:self.conditionalExprParser];
        [assignmentExprParser add:[PKRepetition repetitionWithSubparser:self.assignmentOpConditionalExprParser]];
    }
    return assignmentExprParser;
}


// assignmentOpConditionalExpr     = assignmentOperator conditionalExpr;
- (PKCollectionParser *)assignmentOpConditionalExprParser {
    if (!assignmentOpConditionalExprParser) {
        self.assignmentOpConditionalExprParser = [PKSequence sequence];
        assignmentOpConditionalExprParser.name = @"assignmentOpConditionalExpr";
        [assignmentOpConditionalExprParser add:self.assignmentOpParser];
        [assignmentOpConditionalExprParser add:self.conditionalExprParser];
    }
    return assignmentOpConditionalExprParser;
}


//  ConditionalExpression:
//           OrExpression
//           OrExpression ? AssignmentExpression : AssignmentExpression
//
//    conditionalExpr     = orExpr ternaryExpr?;
- (PKCollectionParser *)conditionalExprParser {
    if (!conditionalExprParser) {
        self.conditionalExprParser = [PKSequence sequence];
        conditionalExprParser.name = @"conditionalExpr";
        [conditionalExprParser add:self.orExprParser];
        [conditionalExprParser add:[self zeroOrOne:self.ternaryExprParser]];
    }
    return conditionalExprParser;
}


//    ternaryExpr         = question assignmentExpr colon assignmentExpr;
- (PKCollectionParser *)ternaryExprParser {
    if (!ternaryExprParser) {
        self.ternaryExprParser = [PKSequence sequence];
        ternaryExprParser.name = @"ternaryExpr";
        [ternaryExprParser add:self.questionParser];
        [ternaryExprParser add:self.assignmentExprParser];
        [ternaryExprParser add:self.colonParser];
        [ternaryExprParser add:self.assignmentExprParser];
    }
    return ternaryExprParser;
}


//  OrExpression:
//           AndExpression
//           AndExpression || OrExpression
//
//    orExpr              = andExpr orAndExpr*;
- (PKCollectionParser *)orExprParser {
    if (!orExprParser) {
        self.orExprParser = [PKSequence sequence];
        orExprParser.name = @"orExpr";
        [orExprParser add:self.andExprParser];
        [orExprParser add:[PKRepetition repetitionWithSubparser:self.orAndExprParser]];
    }
    return orExprParser;
}


//    orAndExpr           = or andExpr;
- (PKCollectionParser *)orAndExprParser {
    if (!orAndExprParser) {
        self.orAndExprParser = [PKSequence sequence];
        orAndExprParser.name = @"orAndExpr";
        [orAndExprParser add:self.orParser];
        [orAndExprParser add:self.andExprParser];
    }
    return orAndExprParser;
}


//  AndExpression:
//           BitwiseOrExpression
//           BitwiseOrExpression && AndExpression
//
//    andExpr             = bitwiseOrExpr andBitwiseOrExprParser*;
- (PKCollectionParser *)andExprParser {
    if (!andExprParser) {
        self.andExprParser = [PKSequence sequence];
        andExprParser.name = @"andExpr";
        [andExprParser add:self.bitwiseOrExprParser];
        [andExprParser add:[PKRepetition repetitionWithSubparser:self.andBitwiseOrExprParser]];
    }
    return andExprParser;
}


//    andBitwiseOrExprParser          = and bitwiseOrExpr;
- (PKCollectionParser *)andBitwiseOrExprParser {
    if (!andBitwiseOrExprParser) {
        self.andBitwiseOrExprParser = [PKSequence sequence];
        andBitwiseOrExprParser.name = @"andBitwiseOrExpr";
        [andBitwiseOrExprParser add:self.andParser];
        [andBitwiseOrExprParser add:self.bitwiseOrExprParser];
    }
    return andBitwiseOrExprParser;
}


//  BitwiseOrExpression:
//           BitwiseXorExpression
//           BitwiseXorExpression | BitwiseOrExpression
//
//    bitwiseOrExpr       = bitwiseXorExpr pipeBitwiseXorExpr*;
- (PKCollectionParser *)bitwiseOrExprParser {
    if (!bitwiseOrExprParser) {
        self.bitwiseOrExprParser = [PKSequence sequence];
        bitwiseOrExprParser.name = @"bitwiseOrExpr";
        [bitwiseOrExprParser add:self.bitwiseXorExprParser];
        [bitwiseOrExprParser add:[PKRepetition repetitionWithSubparser:self.pipeBitwiseXorExprParser]];
    }
    return bitwiseOrExprParser;
}


//    pipeBitwiseXorExprParser   = pipe bitwiseXorExpr;
- (PKCollectionParser *)pipeBitwiseXorExprParser {
    if (!pipeBitwiseXorExprParser) {
        self.pipeBitwiseXorExprParser = [PKSequence sequence];
        pipeBitwiseXorExprParser.name = @"pipeBitwiseXorExpr";
        [pipeBitwiseXorExprParser add:self.pipeParser];
        [pipeBitwiseXorExprParser add:self.bitwiseXorExprParser];
    }
    return pipeBitwiseXorExprParser;
}


//  BitwiseXorExpression:
//           BitwiseAndExpression
//           BitwiseAndExpression ^ BitwiseXorExpression
//
//    bitwiseXorExpr      = bitwiseAndExpr caretBitwiseAndExpr*;
- (PKCollectionParser *)bitwiseXorExprParser {
    if (!bitwiseXorExprParser) {
        self.bitwiseXorExprParser = [PKSequence sequence];
        bitwiseXorExprParser.name = @"bitwiseXorExpr";
        [bitwiseXorExprParser add:self.bitwiseAndExprParser];
        [bitwiseXorExprParser add:[PKRepetition repetitionWithSubparser:self.caretBitwiseAndExprParser]];
    }
    return bitwiseXorExprParser;
}


//    caretBitwiseAndExpr = caret bitwiseAndExpr;
- (PKCollectionParser *)caretBitwiseAndExprParser {
    if (!caretBitwiseAndExprParser) {
        self.caretBitwiseAndExprParser = [PKSequence sequence];
        caretBitwiseAndExprParser.name = @"caretBitwiseAndExpr";
        [caretBitwiseAndExprParser add:self.caretParser];
        [caretBitwiseAndExprParser add:self.bitwiseAndExprParser];
    }
    return caretBitwiseAndExprParser;
}


//  BitwiseAndExpression:
//           EqualityExpression
//           EqualityExpression & BitwiseAndExpression
//
//    bitwiseAndExpr      = equalityExpr ampEqualityExpr*;
- (PKCollectionParser *)bitwiseAndExprParser {
    if (!bitwiseAndExprParser) {
        self.bitwiseAndExprParser = [PKSequence sequence];
        bitwiseAndExprParser.name = @"bitwiseAndExpr";
        [bitwiseAndExprParser add:self.equalityExprParser];
        [bitwiseAndExprParser add:[PKRepetition repetitionWithSubparser:self.ampEqualityExprParser]];
    }
    return bitwiseAndExprParser;
}


//    ampEqualityExpression = amp equalityExpression;
- (PKCollectionParser *)ampEqualityExprParser {
    if (!ampEqualityExprParser) {
        self.ampEqualityExprParser = [PKSequence sequence];
        ampEqualityExprParser.name = @"ampEqualityExpr";
        [ampEqualityExprParser add:self.ampParser];
        [ampEqualityExprParser add:self.equalityExprParser];
    }
    return ampEqualityExprParser;
}


//  EqualityExpression:
//           RelationalExpression
//           RelationalExpression EqualityualityOperator EqualityExpression
//
//    equalityExpr        = relationalExpr equalityOpRelationalExpr*;
- (PKCollectionParser *)equalityExprParser {
    if (!equalityExprParser) {
        self.equalityExprParser = [PKSequence sequence];
        equalityExprParser.name = @"equalityExpr";
        [equalityExprParser add:self.relationalExprParser];
        [equalityExprParser add:[PKRepetition repetitionWithSubparser:self.equalityOpRelationalExprParser]];
    }
    return equalityExprParser;
}


//    equalityOpRelationalExpr = equalityOp relationalExpr;
- (PKCollectionParser *)equalityOpRelationalExprParser {
    if (!equalityOpRelationalExprParser) {
        self.equalityOpRelationalExprParser = [PKSequence sequence];
        equalityOpRelationalExprParser.name = @"equalityOpRelationalExpr";
        [equalityOpRelationalExprParser add:self.equalityOpParser];
        [equalityOpRelationalExprParser add:self.relationalExprParser];
    }
    return equalityOpRelationalExprParser;
}


//  RelationalExpression:
//           ShiftExpression
//           RelationalExpression RelationalationalOperator ShiftExpression
//

//    relationalExpr      = shiftExpr relationalOpShiftExpr*;       /// TODO ????
- (PKCollectionParser *)relationalExprParser {
    if (!relationalExprParser) {
        self.relationalExprParser = [PKSequence sequence];
        relationalExprParser.name = @"relationalExpr";
        [relationalExprParser add:self.shiftExprParser];
        [relationalExprParser add:[PKRepetition repetitionWithSubparser:self.relationalOpShiftExprParser]];
    }
    return relationalExprParser;
}


//    relationalOpShiftExpr   = relationalOperator shiftExpr;
- (PKCollectionParser *)relationalOpShiftExprParser {
    if (!relationalOpShiftExprParser) {
        self.relationalOpShiftExprParser = [PKSequence sequence];
        relationalOpShiftExprParser.name = @"relationalOpShiftExpr";
        [relationalOpShiftExprParser add:self.relationalOpParser];
        [relationalOpShiftExprParser add:self.shiftExprParser];
    }
    return relationalOpShiftExprParser;
}


//  ShiftExpression:
//           AdditiveExpression
//           AdditiveExpression ShiftOperator ShiftExpression
//
//    shiftExpr           = additiveExpr shiftOpAdditiveExpr?;
- (PKCollectionParser *)shiftExprParser {
    if (!shiftExprParser) {
        self.shiftExprParser = [PKSequence sequence];
        shiftExprParser.name = @"shiftExpr";
        [shiftExprParser add:self.additiveExprParser];
        [shiftExprParser add:[PKRepetition repetitionWithSubparser:self.shiftOpAdditiveExprParser]];
    }
    return shiftExprParser;
}


//    shiftOpShiftExpr    = shiftOp additiveExpr;
- (PKCollectionParser *)shiftOpAdditiveExprParser {
    if (!shiftOpAdditiveExprParser) {
        self.shiftOpAdditiveExprParser = [PKSequence sequence];
        shiftOpAdditiveExprParser.name = @"shiftOpShiftExpr";
        [shiftOpAdditiveExprParser add:self.shiftOpParser];
        [shiftOpAdditiveExprParser add:self.additiveExprParser];
    }
    return shiftOpAdditiveExprParser;
}


//  AdditiveExpression:
//           MultiplicativeExpression
//           MultiplicativeExpression + AdditiveExpression
//           MultiplicativeExpression - AdditiveExpression
//
//    additiveExpr        = multiplicativeExpr plusOrMinusExpr*;
- (PKCollectionParser *)additiveExprParser {
    if (!additiveExprParser) {
        self.additiveExprParser = [PKSequence sequence];
        additiveExprParser.name = @"additiveExpr";
        [additiveExprParser add:self.multiplicativeExprParser];
        [additiveExprParser add:[PKRepetition repetitionWithSubparser:self.plusOrMinusExprParser]];
    }
    return additiveExprParser;
}


//    plusOrMinusExpr     = plusExpr | minusExpr;
- (PKCollectionParser *)plusOrMinusExprParser {
    if (!plusOrMinusExprParser) {
        self.plusOrMinusExprParser = [PKAlternation alternation];
        plusOrMinusExprParser.name = @"plusOrMinusExpr";
        [plusOrMinusExprParser add:self.plusExprParser];
        [plusOrMinusExprParser add:self.minusExprParser];
    }
    return plusOrMinusExprParser;
}


//    plusExpr            = plus multiplicativeExprParser;
- (PKCollectionParser *)plusExprParser {
    if (!plusExprParser) {
        self.plusExprParser = [PKSequence sequence];
        plusExprParser.name = @"plusExpr";
        [plusExprParser add:self.plusParser];
        [plusExprParser add:self.multiplicativeExprParser];
    }
    return plusExprParser;
}


//    minusExpr           = minus multiplicativeExprParser;
- (PKCollectionParser *)minusExprParser {
    if (!minusExprParser) {
        self.minusExprParser = [PKSequence sequence];
        minusExprParser.name = @"minusExpr";
        [minusExprParser add:self.minusParser];
        [minusExprParser add:self.multiplicativeExprParser];
    }
    return minusExprParser;
}


//  MultiplicativeExpression:
//           UnaryExpression
//           UnaryExpression MultiplicativeOperator MultiplicativeExpression
//
//    multiplicativeExpr  = unaryExpr multiplicativeOpUnaryExpr*;
- (PKCollectionParser *)multiplicativeExprParser {
    if (!multiplicativeExprParser) {
        self.multiplicativeExprParser = [PKSequence sequence];
        multiplicativeExprParser.name = @"multiplicativeExpr";
        [multiplicativeExprParser add:self.unaryExprParser];
        [multiplicativeExprParser add:[PKRepetition repetitionWithSubparser:self.multiplicativeOpUnaryExprParser]];
    }
    return multiplicativeExprParser;
}


// multiplicativeOpUnaryExpr = multiplicativeOp unaryExpr;
- (PKCollectionParser *)multiplicativeOpUnaryExprParser {
    if (!multiplicativeOpUnaryExprParser) {
        self.multiplicativeOpUnaryExprParser = [PKSequence sequence];
        multiplicativeOpUnaryExprParser.name = @"multiplicativeOpUnaryExpr";
        [multiplicativeOpUnaryExprParser add:self.multiplicativeOpParser];
        [multiplicativeOpUnaryExprParser add:self.unaryExprParser];
    }
    return multiplicativeOpUnaryExprParser;
}


//  UnaryExpression:
//           MemberExpression
//           UnaryOperator UnaryExpression
//           - UnaryExpression
//           IncrementOperator MemberExpression
//           MemberExpression IncrementOperator
//           new Constructor
//           delete MemberExpression
//
//    unaryExpr           = memberExpr | unaryExpr1 | unaryExpr2 | unaryExpr3 | unaryExpr4 | unaryExpr5 | unaryExpr6;
- (PKCollectionParser *)unaryExprParser {
    if (!unaryExprParser) {
        self.unaryExprParser = [PKAlternation alternation];
        unaryExprParser.name = @"unaryExpr";
        [unaryExprParser add:self.memberExprParser];
        [unaryExprParser add:self.unaryExpr1Parser];
        [unaryExprParser add:self.unaryExpr2Parser];
        [unaryExprParser add:self.unaryExpr3Parser];
        [unaryExprParser add:self.unaryExpr4Parser];
        [unaryExprParser add:self.unaryExpr5Parser];
        [unaryExprParser add:self.unaryExpr6Parser];
    }
    return unaryExprParser;
}


//    unaryExpr1          = unaryOperator unaryExpr;
- (PKCollectionParser *)unaryExpr1Parser {
    if (!unaryExpr1Parser) {
        self.unaryExpr1Parser = [PKSequence sequence];
        unaryExpr1Parser.name = @"unaryExpr1";
        [unaryExpr1Parser add:self.unaryOpParser];
        [unaryExpr1Parser add:self.unaryExprParser];
    }
    return unaryExpr1Parser;
}


//    unaryExpr2          = minus unaryExpr;
- (PKCollectionParser *)unaryExpr2Parser {
    if (!unaryExpr2Parser) {
        self.unaryExpr2Parser = [PKSequence sequence];
        unaryExpr2Parser.name = @"unaryExpr2";
        [unaryExpr2Parser add:self.minusParser];
        [unaryExpr2Parser add:self.unaryExprParser];
    }
    return unaryExpr2Parser;
}


//    unaryExpr3          = incrementOperator memberExpr;
- (PKCollectionParser *)unaryExpr3Parser {
    if (!unaryExpr3Parser) {
        self.unaryExpr3Parser = [PKSequence sequence];
        unaryExpr3Parser.name = @"unaryExpr3";
        [unaryExpr3Parser add:self.incrementOpParser];
        [unaryExpr3Parser add:self.memberExprParser];
    }
    return unaryExpr3Parser;
}


//    unaryExpr4          = memberExpr incrementOperator;
- (PKCollectionParser *)unaryExpr4Parser {
    if (!unaryExpr4Parser) {
        self.unaryExpr4Parser = [PKSequence sequence];
        unaryExpr4Parser.name = @"unaryExpr4";
        [unaryExpr4Parser add:self.memberExprParser];
        [unaryExpr4Parser add:self.incrementOpParser];
    }
    return unaryExpr4Parser;
}


//    unaryExpr5          = new constructor;
- (PKCollectionParser *)unaryExpr5Parser {
    if (!unaryExpr5Parser) {
        self.unaryExpr5Parser = [PKSequence sequence];
        unaryExpr5Parser.name = @"unaryExpr5";
        [unaryExpr5Parser add:self.newParser];
        [unaryExpr5Parser add:self.constructorCallParser];
    }
    return unaryExpr5Parser;
}


//    unaryExpr6          = delete memberExpr;
- (PKCollectionParser *)unaryExpr6Parser {
    if (!unaryExpr6Parser) {
        self.unaryExpr6Parser = [PKSequence sequence];
        unaryExpr6Parser.name = @"unaryExpr6";
        [unaryExpr6Parser add:self.deleteParser];
        [unaryExpr6Parser add:self.memberExprParser];
    }
    return unaryExpr6Parser;
}


//  ConstructorCall:
//           Identifier
//           Identifier ( ArgumentListOpt )
//           Identifier . ConstructorCall
//

// constructorCall = identifier parentArgListOptParent? memberExprExt*
- (PKCollectionParser *)constructorCallParser {
    if (!constructorCallParser) {
        self.constructorCallParser = [PKSequence sequence];
        constructorCallParser.name = @"constructorCall";
        [constructorCallParser add:self.identifierParser];
        [constructorCallParser add:[self zeroOrOne:self.parenArgListOptParenParser]];
        [constructorCallParser add:[PKRepetition repetitionWithSubparser:self.memberExprExtParser]];
    }
    return constructorCallParser;
}


//    parenArgListParen   = openParen argListOpt closeParen;
- (PKCollectionParser *)parenArgListOptParenParser {
    if (!parenArgListOptParenParser) {
        self.parenArgListOptParenParser = [PKSequence sequence];
        parenArgListOptParenParser.name = @"parenArgListParen";
        [parenArgListOptParenParser add:self.openParenParser];
        [parenArgListOptParenParser add:self.argListOptParser];
        [parenArgListOptParenParser add:self.closeParenParser];
    }
    return parenArgListOptParenParser;
}


//  MemberExpression:
//           PrimaryExpression
//           PrimaryExpression . MemberExpression
//           PrimaryExpression [ Expression ]
//           PrimaryExpression ( ArgumentListOpt )
//
//    memberExpr          = primaryExpr memberExprExt?;    // TODO ??????
- (PKCollectionParser *)memberExprParser {
    if (!memberExprParser) {
        self.memberExprParser = [PKSequence sequence];
        memberExprParser.name = @"memberExpr";
        [memberExprParser add:self.primaryExprParser];
        [memberExprParser add:[PKRepetition repetitionWithSubparser:self.memberExprExtParser]];
    }
    return memberExprParser;
}


//    memberExprExt = dotMemberExpr | bracketMemberExpr | parenMemberExpr;
- (PKCollectionParser *)memberExprExtParser {
    if (!memberExprExtParser) {
        self.memberExprExtParser = [PKAlternation alternation];
        memberExprExtParser.name = @"memberExprExt";
        [memberExprExtParser add:self.dotMemberExprParser];
        [memberExprExtParser add:self.bracketMemberExprParser];
        [memberExprExtParser add:self.parenArgListOptParenParser];
    }
    return memberExprExtParser;
}


//    dotMemberExpr       = dot memberExpr;
- (PKCollectionParser *)dotMemberExprParser {
    if (!dotMemberExprParser) {
        self.dotMemberExprParser = [PKSequence sequence];
        dotMemberExprParser.name = @"dotMemberExpr";
        [dotMemberExprParser add:self.dotParser];
        [dotMemberExprParser add:self.memberExprParser];
    }
    return dotMemberExprParser;
}


//    bracketMemberExpr   = openBracket expr closeBracket;
- (PKCollectionParser *)bracketMemberExprParser {
    if (!bracketMemberExprParser) {
        self.bracketMemberExprParser = [PKSequence sequence];
        bracketMemberExprParser.name = @"bracketMemberExpr";
        [bracketMemberExprParser add:self.openBracketParser];
        [bracketMemberExprParser add:self.exprParser];
        [bracketMemberExprParser add:self.closeBracketParser];
    }
    return bracketMemberExprParser;
}


//  ArgumentListOpt:
//           empty
//           ArgumentList
//
// argListOpt          = argList?;
- (PKCollectionParser *)argListOptParser {
    if (!argListOptParser) {
        self.argListOptParser = [self zeroOrOne:self.argListParser];
        argListOptParser.name = @"argListOpt";
    }
    return argListOptParser;
}


//  ArgumentList:
//           AssignmentExpression
//           AssignmentExpression , ArgumentList
//
// argList             = assignmentExpr commaAssignmentExpr*;
- (PKCollectionParser *)argListParser {
    if (!argListParser) {
        self.argListParser = [PKSequence sequence];
        argListParser.name = @"argList";
        [argListParser add:self.assignmentExprParser];
        [argListParser add:[PKRepetition repetitionWithSubparser:self.commaAssignmentExprParser]];
    }
    return argListParser;
}


 //  PrimaryExpression:
 //           ( Expression )
 //           funcLiteral
 //           arrayLiteral
 //           Identifier
 //           IntegerLiteral
 //           FloatingPointLiteral
 //           StringLiteral
 //           false
 //           true
 //           null
 //           this
// primaryExpr         = parenExprParen | funcLiteral | arrayLiteral | identifier | Number | QuotedString | false | true | null | undefined | this;
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.parenExprParenParser];
        [primaryExprParser add:self.funcLiteralParser];
        [primaryExprParser add:self.arrayLiteralParser];
        [primaryExprParser add:self.objectLiteralParser];
        [primaryExprParser add:self.identifierParser];
        [primaryExprParser add:self.numberParser];
        [primaryExprParser add:self.stringParser];
        [primaryExprParser add:self.trueParser];
        [primaryExprParser add:self.falseParser];
        [primaryExprParser add:self.nullParser];
        [primaryExprParser add:self.undefinedParser]; // TODO ??
        [primaryExprParser add:self.thisParser];
    }
    return primaryExprParser;
}

 
 
//  parenExprParen      = openParen expr closeParen;
- (PKCollectionParser *)parenExprParenParser {
    if (!parenExprParenParser) {
        self.parenExprParenParser = [PKSequence sequence];
        parenExprParenParser.name = @"parenExprParen";
        [parenExprParenParser add:self.openParenParser];
        [parenExprParenParser add:self.exprParser];
        [parenExprParenParser add:self.closeParenParser];
    }
    return parenExprParenParser;
}


//funcLiteral                = function openParen paramListOpt closeParen compoundStmt;
- (PKCollectionParser *)funcLiteralParser {
    if (!funcLiteralParser) {
        self.funcLiteralParser = [PKSequence sequence];
        funcLiteralParser.name = @"funcLiteral";
        [funcLiteralParser add:self.functionParser];
        [funcLiteralParser add:self.openParenParser];
        [funcLiteralParser add:self.paramListOptParser];
        [funcLiteralParser add:self.closeParenParser];
        [funcLiteralParser add:self.compoundStmtParser];
    }
    return funcLiteralParser;
}


//arrayLiteral                = '[' arrayContents ']';
- (PKCollectionParser *)arrayLiteralParser {
    if (!arrayLiteralParser) {
        self.arrayLiteralParser = [PKTrack track];
        arrayLiteralParser.name = @"arrayLiteralParser";
        
        PKSequence *commaPrimaryExpr = [PKSequence sequence];
        [commaPrimaryExpr add:self.commaParser];
        [commaPrimaryExpr add:self.primaryExprParser];

        PKSequence *arrayContents = [PKSequence sequence];
        [arrayContents add:self.primaryExprParser];
        [arrayContents add:[PKRepetition repetitionWithSubparser:commaPrimaryExpr]];

        PKAlternation *arrayContentsOpt = [PKAlternation alternation];
        [arrayContentsOpt add:[PKEmpty empty]];
        [arrayContentsOpt add:arrayContents];

        [arrayLiteralParser add:self.openBracketParser];
        [arrayLiteralParser add:arrayContentsOpt];
        [arrayLiteralParser add:self.closeBracketParser];
    }
    return arrayLiteralParser;
}


//objectLiteral                = '{' objectContentsOpt '}';
- (PKCollectionParser *)objectLiteralParser {
    if (!objectLiteralParser) {
        self.objectLiteralParser = [PKSequence sequence];
        objectLiteralParser.name = @"objectLiteralParser";

        PKSequence *member = [PKSequence sequence];
        [member add:self.identifierParser];
        [member add:self.colonParser];
        [member add:self.primaryExprParser];

        PKSequence *commaMember = [PKSequence sequence];
        [commaMember add:self.commaParser];
        [commaMember add:member];
        
        PKSequence *objectContents = [PKSequence sequence];
        [objectContents add:member];
        [objectContents add:[PKRepetition repetitionWithSubparser:commaMember]];
        
        PKAlternation *objectContentsOpt = [PKAlternation alternation];
        [objectContentsOpt add:[PKEmpty empty]];
        [objectContentsOpt add:objectContents];
        
        [objectLiteralParser add:self.openCurlyParser];
        [objectLiteralParser add:objectContentsOpt];
        [objectLiteralParser add:self.closeCurlyParser];
    }
    return objectLiteralParser;
}


//  identifier          = Word;
- (PKParser *)identifierParser {
    if (!identifierParser) {
        self.identifierParser = [PKWord word];
        identifierParser.name = @"identifier";
    }
    return identifierParser;
}


- (PKParser *)stringParser {
    if (!stringParser) {
        self.stringParser = [PKQuotedString quotedString];
        stringParser.name = @"string";
    }
    return stringParser;
}


- (PKParser *)numberParser {
    if (!numberParser) {
        self.numberParser = [PKNumber number];
        numberParser.name = @"number";
    }
    return numberParser;
}


#pragma mark -
#pragma mark keywords

- (PKParser *)ifParser {
    if (!ifParser) {
        self.ifParser = [PKLiteral literalWithString:@"if"];
        ifParser.name = @"if";
    }
    return ifParser;
}


- (PKParser *)elseParser {
    if (!elseParser) {
        self.elseParser = [PKLiteral literalWithString:@"else"];
        elseParser.name = @"else";
    }
    return elseParser;
}


- (PKParser *)whileParser {
    if (!whileParser) {
        self.whileParser = [PKLiteral literalWithString:@"while"];
        whileParser.name = @"while";
    }
    return whileParser;
}


- (PKParser *)forParser {
    if (!forParser) {
        self.forParser = [PKLiteral literalWithString:@"for"];
        forParser.name = @"for";
    }
    return forParser;
}


- (PKParser *)inParser {
    if (!inParser) {
        self.inParser = [PKLiteral literalWithString:@"in"];
        inParser.name = @"in";
    }
    return inParser;
}


- (PKParser *)breakParser {
    if (!breakParser) {
        self.breakParser = [PKLiteral literalWithString:@"break"];
        breakParser.name = @"break";
    }
    return breakParser;
}


- (PKParser *)continueParser {
    if (!continueParser) {
        self.continueParser = [PKLiteral literalWithString:@"continue"];
        continueParser.name = @"continue";
    }
    return continueParser;
}


- (PKParser *)withParser {
    if (!withParser) {
        self.withParser = [PKLiteral literalWithString:@"with"];
        withParser.name = @"with";
    }
    return withParser;
}


- (PKParser *)returnParser {
    if (!returnParser) {
        self.returnParser = [PKLiteral literalWithString:@"return"];
        returnParser.name = @"return";
    }
    return returnParser;
}


- (PKParser *)varParser {
    if (!varParser) {
        self.varParser = [PKLiteral literalWithString:@"var"];
        varParser.name = @"var";
    }
    return varParser;
}


- (PKParser *)deleteParser {
    if (!deleteParser) {
        self.deleteParser = [PKLiteral literalWithString:@"delete"];
        deleteParser.name = @"delete";
    }
    return deleteParser;
}


- (PKParser *)newParser {
    if (!newParser) {
        self.newParser = [PKLiteral literalWithString:@"new"];
        newParser.name = @"new";
    }
    return newParser;
}


- (PKParser *)thisParser {
    if (!thisParser) {
        self.thisParser = [PKLiteral literalWithString:@"this"];
        thisParser.name = @"this";
    }
    return thisParser;
}


- (PKParser *)falseParser {
    if (!falseParser) {
        self.falseParser = [PKLiteral literalWithString:@"false"];
        falseParser.name = @"false";
    }
    return falseParser;
}


- (PKParser *)trueParser {
    if (!trueParser) {
        self.trueParser = [PKLiteral literalWithString:@"true"];
        trueParser.name = @"true";
    }
    return trueParser;
}


- (PKParser *)nullParser {
    if (!nullParser) {
        self.nullParser = [PKLiteral literalWithString:@"null"];
        nullParser.name = @"null";
    }
    return nullParser;
}


- (PKParser *)undefinedParser {
    if (!undefinedParser) {
        self.undefinedParser = [PKLiteral literalWithString:@"undefined"];
        undefinedParser.name = @"undefined";
    }
    return undefinedParser;
}


- (PKParser *)voidParser {
    if (!voidParser) {
        self.voidParser = [PKLiteral literalWithString:@"void"];
        voidParser.name = @"void";
    }
    return voidParser;
}


- (PKParser *)typeofParser {
    if (!typeofParser) {
        self.typeofParser = [PKLiteral literalWithString:@"typeof"];
        typeofParser.name = @"typeof";
    }
    return typeofParser;
}


- (PKParser *)instanceofParser {
    if (!instanceofParser) {
        self.instanceofParser = [PKLiteral literalWithString:@"instanceof"];
        instanceofParser.name = @"instanceof";
    }
    return instanceofParser;
}


- (PKParser *)functionParser {
    if (!functionParser) {
        self.functionParser = [PKLiteral literalWithString:@"function"];
        functionParser.name = @"function";
    }
    return functionParser;
}


#pragma mark -
#pragma mark single-char symbols

- (PKParser *)orParser {
    if (!orParser) {
        self.orParser = [PKSymbol symbolWithString:@"||"];
        orParser.name = @"or";
    }
    return orParser;
}


- (PKParser *)andParser {
    if (!andParser) {
        self.andParser = [PKSymbol symbolWithString:@"&&"];
        andParser.name = @"and";
    }
    return andParser;
}


- (PKParser *)neParser {
    if (!neParser) {
        self.neParser = [PKSymbol symbolWithString:@"!="];
        neParser.name = @"ne";
    }
    return neParser;
}


- (PKParser *)isNotParser {
    if (!isNotParser) {
        self.isNotParser = [PKSymbol symbolWithString:@"!=="];
        isNotParser.name = @"isNot";
    }
    return isNotParser;
}


- (PKParser *)eqParser {
    if (!eqParser) {
        self.eqParser = [PKSymbol symbolWithString:@"=="];
        eqParser.name = @"eq";
    }
    return eqParser;
}


- (PKParser *)isParser {
    if (!isParser) {
        self.isParser = [PKSymbol symbolWithString:@"==="];
        isParser.name = @"is";
    }
    return isParser;
}


- (PKParser *)leParser {
    if (!leParser) {
        self.leParser = [PKSymbol symbolWithString:@"<="];
        leParser.name = @"le";
    }
    return leParser;
}


- (PKParser *)geParser {
    if (!geParser) {
        self.geParser = [PKSymbol symbolWithString:@">="];
        geParser.name = @"ge";
    }
    return geParser;
}


- (PKParser *)plusPlusParser {
    if (!plusPlusParser) {
        self.plusPlusParser = [PKSymbol symbolWithString:@"++"];
        plusPlusParser.name = @"plusPlus";
    }
    return plusPlusParser;
}


- (PKParser *)minusMinusParser {
    if (!minusMinusParser) {
        self.minusMinusParser = [PKSymbol symbolWithString:@"--"];
        minusMinusParser.name = @"minusMinus";
    }
    return minusMinusParser;
}


- (PKParser *)plusEqParser {
    if (!plusEqParser) {
        self.plusEqParser = [PKSymbol symbolWithString:@"+="];
        plusEqParser.name = @"plusEq";
    }
    return plusEqParser;
}


- (PKParser *)minusEqParser {
    if (!minusEqParser) {
        self.minusEqParser = [PKSymbol symbolWithString:@"-="];
        minusEqParser.name = @"minusEq";
    }
    return minusEqParser;
}


- (PKParser *)timesEqParser {
    if (!timesEqParser) {
        self.timesEqParser = [PKSymbol symbolWithString:@"*="];
        timesEqParser.name = @"timesEq";
    }
    return timesEqParser;
}


- (PKParser *)divEqParser {
    if (!divEqParser) {
        self.divEqParser = [PKSymbol symbolWithString:@"/="];
        divEqParser.name = @"divEq";
    }
    return divEqParser;
}


- (PKParser *)modEqParser {
    if (!modEqParser) {
        self.modEqParser = [PKSymbol symbolWithString:@"%="];
        modEqParser.name = @"modEq";
    }
    return modEqParser;
}


- (PKParser *)shiftLeftParser {
    if (!shiftLeftParser) {
        self.shiftLeftParser = [PKSymbol symbolWithString:@"<<"];
        shiftLeftParser.name = @"shiftLeft";
    }
    return shiftLeftParser;
}


- (PKParser *)shiftRightParser {
    if (!shiftRightParser) {
        self.shiftRightParser = [PKSymbol symbolWithString:@">>"];
        shiftRightParser.name = @"shiftRight";
    }
    return shiftRightParser;
}


- (PKParser *)shiftRightExtParser {
    if (!shiftRightExtParser) {
        self.shiftRightExtParser = [PKSymbol symbolWithString:@">>>"];
        shiftRightExtParser.name = @"shiftRightExt";
    }
    return shiftRightExtParser;
}


- (PKParser *)shiftLeftEqParser {
    if (!shiftLeftEqParser) {
        self.shiftLeftEqParser = [PKSymbol symbolWithString:@"<<="];
        shiftLeftEqParser.name = @"shiftLeftEq";
    }
    return shiftLeftEqParser;
}


- (PKParser *)shiftRightEqParser {
    if (!shiftRightEqParser) {
        self.shiftRightEqParser = [PKSymbol symbolWithString:@">>="];
        shiftRightEqParser.name = @"shiftRightEq";
    }
    return shiftRightEqParser;
}


- (PKParser *)shiftRightExtEqParser {
    if (!shiftRightExtEqParser) {
        self.shiftRightExtEqParser = [PKSymbol symbolWithString:@">>>="];
        shiftRightExtEqParser.name = @"shiftRightExtEq";
    }
    return shiftRightExtEqParser;
}


- (PKParser *)andEqParser {
    if (!andEqParser) {
        self.andEqParser = [PKSymbol symbolWithString:@"&="];
        andEqParser.name = @"andEq";
    }
    return andEqParser;
}


- (PKParser *)xorEqParser {
    if (!xorEqParser) {
        self.xorEqParser = [PKSymbol symbolWithString:@"^="];
        xorEqParser.name = @"xorEq";
    }
    return xorEqParser;
}


- (PKParser *)orEqParser {
    if (!orEqParser) {
        self.orEqParser = [PKSymbol symbolWithString:@"|="];
        orEqParser.name = @"orEq";
    }
    return orEqParser;
}


#pragma mark -
#pragma mark single-char symbols

- (PKParser *)openCurlyParser {
    if (!openCurlyParser) {
        self.openCurlyParser = [PKSymbol symbolWithString:@"{"];
        openCurlyParser.name = @"openCurly";
    }
    return openCurlyParser;
}


- (PKParser *)closeCurlyParser {
    if (!closeCurlyParser) {
        self.closeCurlyParser = [PKSymbol symbolWithString:@"}"];
        closeCurlyParser.name = @"closeCurly";
    }
    return closeCurlyParser;
}


- (PKParser *)openParenParser {
    if (!openParenParser) {
        self.openParenParser = [PKSymbol symbolWithString:@"("];
        openParenParser.name = @"openParen";
    }
    return openParenParser;
}


- (PKParser *)closeParenParser {
    if (!closeParenParser) {
        self.closeParenParser = [PKSymbol symbolWithString:@")"];
        closeParenParser.name = @"closeParen";
    }
    return closeParenParser;
}


- (PKParser *)openBracketParser {
    if (!openBracketParser) {
        self.openBracketParser = [PKSymbol symbolWithString:@"["];
        openBracketParser.name = @"openBracket";
    }
    return openBracketParser;
}


- (PKParser *)closeBracketParser {
    if (!closeBracketParser) {
        self.closeBracketParser = [PKSymbol symbolWithString:@"]"];
        closeBracketParser.name = @"closeBracket";
    }
    return closeBracketParser;
}


- (PKParser *)commaParser {
    if (!commaParser) {
        self.commaParser = [PKSymbol symbolWithString:@","];
        commaParser.name = @"comma";
    }
    return commaParser;
}


- (PKParser *)dotParser {
    if (!dotParser) {
        self.dotParser = [PKSymbol symbolWithString:@"."];
        dotParser.name = @"dot";
    }
    return dotParser;
}


- (PKParser *)semiOptParser {
    if (!semiOptParser) {
        self.semiOptParser = [self zeroOrOne:self.semiParser];
        semiOptParser.name = @"semiOpt";
    }
    return semiOptParser;
}


- (PKParser *)semiParser {
    if (!semiParser) {
        self.semiParser = [PKSymbol symbolWithString:@";"];
        semiParser.name = @"semi";
    }
    return semiParser;
}


- (PKParser *)colonParser {
    if (!colonParser) {
        self.colonParser = [PKSymbol symbolWithString:@":"];
        colonParser.name = @"colon";
    }
    return colonParser;
}


- (PKParser *)equalsParser {
    if (!equalsParser) {
        self.equalsParser = [PKSymbol symbolWithString:@"="];
        equalsParser.name = @"equals";
    }
    return equalsParser;
}


- (PKParser *)notParser {
    if (!notParser) {
        self.notParser = [PKSymbol symbolWithString:@"!"];
        notParser.name = @"not";
    }
    return notParser;
}


- (PKParser *)ltParser {
    if (!ltParser) {
        self.ltParser = [PKSymbol symbolWithString:@"<"];
        ltParser.name = @"lt";
    }
    return ltParser;
}


- (PKParser *)gtParser {
    if (!gtParser) {
        self.gtParser = [PKSymbol symbolWithString:@">"];
        gtParser.name = @"gt";
    }
    return gtParser;
}


- (PKParser *)ampParser {
    if (!ampParser) {
        self.ampParser = [PKSymbol symbolWithString:@"&"];
        ampParser.name = @"amp";
    }
    return ampParser;
}


- (PKParser *)pipeParser {
    if (!pipeParser) {
        self.pipeParser = [PKSymbol symbolWithString:@"|"];
        pipeParser.name = @"pipe";
    }
    return pipeParser;
}


- (PKParser *)caretParser {
    if (!caretParser) {
        self.caretParser = [PKSymbol symbolWithString:@"^"];
        caretParser.name = @"caret";
    }
    return caretParser;
}


- (PKParser *)tildeParser {
    if (!tildeParser) {
        self.tildeParser = [PKSymbol symbolWithString:@"~"];
        tildeParser.name = @"tilde";
    }
    return tildeParser;
}


- (PKParser *)questionParser {
    if (!questionParser) {
        self.questionParser = [PKSymbol symbolWithString:@"?"];
        questionParser.name = @"question";
    }
    return questionParser;
}


- (PKParser *)plusParser {
    if (!plusParser) {
        self.plusParser = [PKSymbol symbolWithString:@"+"];
        plusParser.name = @"plus";
    }
    return plusParser;
}


- (PKParser *)minusParser {
    if (!minusParser) {
        self.minusParser = [PKSymbol symbolWithString:@"-"];
        minusParser.name = @"minus";
    }
    return minusParser;
}


- (PKParser *)timesParser {
    if (!timesParser) {
        self.timesParser = [PKSymbol symbolWithString:@"x"];
        timesParser.name = @"times";
    }
    return timesParser;
}


- (PKParser *)divParser {
    if (!divParser) {
        self.divParser = [PKSymbol symbolWithString:@"/"];
        divParser.name = @"div";
    }
    return divParser;
}


- (PKParser *)modParser {
    if (!modParser) {
        self.modParser = [PKSymbol symbolWithString:@"%"];
        modParser.name = @"mod";
    }
    return modParser;
}

@synthesize assignmentOpParser;
@synthesize relationalOpParser;
@synthesize equalityOpParser;
@synthesize shiftOpParser;
@synthesize incrementOpParser;
@synthesize unaryOpParser;
@synthesize multiplicativeOpParser;

@synthesize programParser;
@synthesize elementParser;
@synthesize funcParser;
@synthesize paramListOptParser;
@synthesize paramListParser;
@synthesize commaIdentifierParser;
@synthesize compoundStmtParser;
@synthesize stmtsParser;
@synthesize stmtParser;
@synthesize ifStmtParser;
@synthesize ifElseStmtParser;
@synthesize whileStmtParser;
@synthesize forParenStmtParser;
@synthesize forBeginStmtParser;
@synthesize forInStmtParser;
@synthesize breakStmtParser;
@synthesize continueStmtParser;
@synthesize withStmtParser;
@synthesize returnStmtParser;
@synthesize variablesOrExprStmtParser;
@synthesize conditionParser;
@synthesize forParenParser;
@synthesize forBeginParser;
@synthesize variablesOrExprParser;
@synthesize varVariablesParser;
@synthesize variablesParser;
@synthesize commaVariableParser;
@synthesize variableParser;
@synthesize assignmentParser;
@synthesize exprOptParser;
@synthesize exprParser;
@synthesize commaAssignmentExprParser;
@synthesize assignmentExprParser;
@synthesize assignmentOpConditionalExprParser;
@synthesize conditionalExprParser;
@synthesize ternaryExprParser;
@synthesize orExprParser;
@synthesize orAndExprParser;
@synthesize andExprParser;
@synthesize andBitwiseOrExprParser;
@synthesize bitwiseOrExprParser;
@synthesize pipeBitwiseXorExprParser;
@synthesize bitwiseXorExprParser;
@synthesize caretBitwiseAndExprParser;
@synthesize bitwiseAndExprParser;
@synthesize ampEqualityExprParser;
@synthesize equalityExprParser;
@synthesize equalityOpRelationalExprParser;
@synthesize relationalExprParser;
@synthesize relationalOpShiftExprParser;
@synthesize shiftExprParser;
@synthesize shiftOpAdditiveExprParser;
@synthesize additiveExprParser;
@synthesize plusOrMinusExprParser;
@synthesize plusExprParser;
@synthesize minusExprParser;
@synthesize multiplicativeExprParser;
@synthesize multiplicativeOpUnaryExprParser;
@synthesize unaryExprParser;
@synthesize unaryExpr1Parser;
@synthesize unaryExpr2Parser;
@synthesize unaryExpr3Parser;
@synthesize unaryExpr4Parser;
@synthesize unaryExpr5Parser;
@synthesize unaryExpr6Parser;
@synthesize constructorCallParser;
@synthesize parenArgListOptParenParser;
@synthesize memberExprParser;
@synthesize memberExprExtParser;
@synthesize dotMemberExprParser;
@synthesize bracketMemberExprParser;
@synthesize argListOptParser;
@synthesize argListParser;
@synthesize primaryExprParser;
@synthesize parenExprParenParser;

@synthesize funcLiteralParser;
@synthesize arrayLiteralParser;
@synthesize objectLiteralParser;

@synthesize identifierParser;
@synthesize stringParser;
@synthesize numberParser;

@synthesize ifParser;
@synthesize elseParser;
@synthesize whileParser;
@synthesize forParser;
@synthesize inParser;
@synthesize breakParser;
@synthesize continueParser;
@synthesize withParser;
@synthesize returnParser;
@synthesize varParser;
@synthesize deleteParser;
@synthesize newParser;
@synthesize thisParser;
@synthesize falseParser;
@synthesize trueParser;
@synthesize nullParser;
@synthesize undefinedParser;
@synthesize voidParser;
@synthesize typeofParser;
@synthesize instanceofParser;
@synthesize functionParser;
            
@synthesize orParser;
@synthesize andParser;
@synthesize neParser;
@synthesize isNotParser;
@synthesize eqParser;
@synthesize isParser;
@synthesize leParser;
@synthesize geParser;
@synthesize plusPlusParser;
@synthesize minusMinusParser;
@synthesize plusEqParser;
@synthesize minusEqParser;
@synthesize timesEqParser;
@synthesize divEqParser;
@synthesize modEqParser;
@synthesize shiftLeftParser;
@synthesize shiftRightParser;
@synthesize shiftRightExtParser;
@synthesize shiftLeftEqParser;
@synthesize shiftRightEqParser;
@synthesize shiftRightExtEqParser;
@synthesize andEqParser;
@synthesize xorEqParser;
@synthesize orEqParser;
            
@synthesize openCurlyParser;
@synthesize closeCurlyParser;
@synthesize openParenParser;
@synthesize closeParenParser;
@synthesize openBracketParser;
@synthesize closeBracketParser;
@synthesize commaParser;
@synthesize dotParser;
@synthesize semiOptParser;
@synthesize semiParser;
@synthesize colonParser;
@synthesize equalsParser;
@synthesize notParser;
@synthesize ltParser;
@synthesize gtParser;
@synthesize ampParser;
@synthesize pipeParser;
@synthesize caretParser;
@synthesize tildeParser;
@synthesize questionParser;
@synthesize plusParser;
@synthesize minusParser;
@synthesize timesParser;
@synthesize divParser;
@synthesize modParser;
@end
