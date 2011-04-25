//
//  XPathParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@class XPathAssembler;
@class PKAssembly;

@interface XPathParser : PKSequence {
    XPathAssembler *xpathAssembler;
    PKCollectionParser *locationPath;
    PKCollectionParser *absoluteLocationPath;
    PKCollectionParser *relativeLocationPath;
    PKCollectionParser *step;
    PKCollectionParser *axisSpecifier;
    PKCollectionParser *axisName;
    PKCollectionParser *nodeTest;
    PKCollectionParser *predicate;
    PKCollectionParser *predicateExpr;
    PKCollectionParser *abbreviatedAbsoluteLocationPath;
    PKCollectionParser *abbreviatedRelativeLocationPath;
    PKCollectionParser *abbreviatedStep;
    PKCollectionParser *abbreviatedAxisSpecifier;
    PKCollectionParser *expr;
    PKCollectionParser *primaryExpr;
    PKCollectionParser *functionCall;
    PKCollectionParser *argument;
    PKCollectionParser *unionExpr;
    PKCollectionParser *pathExpr;
    PKCollectionParser *filterExpr;
    PKCollectionParser *orExpr;
    PKCollectionParser *andExpr;
    PKCollectionParser *equalityExpr;
    PKCollectionParser *relationalExpr;
    PKCollectionParser *additiveExpr;
    PKCollectionParser *multiplicativeExpr;
    PKCollectionParser *unaryExpr;
    PKCollectionParser *exprToken;
    PKParser *literal;
    PKParser *number;
    PKCollectionParser *operator;
    PKCollectionParser *operatorName;
    PKParser *multiplyOperator;
    PKParser *functionName;
    PKCollectionParser *variableReference;
    PKCollectionParser *nameTest;
    PKCollectionParser *nodeType;
    PKCollectionParser *QName;
}
- (id)parse:(NSString *)s;
- (PKAssembly *)assemblyWithString:(NSString *)s;

@property (retain) PKCollectionParser *locationPath;
@property (retain) PKCollectionParser *absoluteLocationPath;
@property (retain) PKCollectionParser *relativeLocationPath;
@property (retain) PKCollectionParser *step;
@property (retain) PKCollectionParser *axisSpecifier;
@property (retain) PKCollectionParser *axisName;
@property (retain) PKCollectionParser *nodeTest;
@property (retain) PKCollectionParser *predicate;
@property (retain) PKCollectionParser *predicateExpr;
@property (retain) PKCollectionParser *abbreviatedAbsoluteLocationPath;
@property (retain) PKCollectionParser *abbreviatedRelativeLocationPath;
@property (retain) PKCollectionParser *abbreviatedStep;
@property (retain) PKCollectionParser *abbreviatedAxisSpecifier;
@property (retain) PKCollectionParser *expr;
@property (retain) PKCollectionParser *primaryExpr;
@property (retain) PKCollectionParser *functionCall;
@property (retain) PKCollectionParser *argument;
@property (retain) PKCollectionParser *unionExpr;
@property (retain) PKCollectionParser *pathExpr;
@property (retain) PKCollectionParser *filterExpr;
@property (retain) PKCollectionParser *orExpr;
@property (retain) PKCollectionParser *andExpr;
@property (retain) PKCollectionParser *equalityExpr;
@property (retain) PKCollectionParser *relationalExpr;
@property (retain) PKCollectionParser *additiveExpr;
@property (retain) PKCollectionParser *multiplicativeExpr;
@property (retain) PKCollectionParser *unaryExpr;
@property (retain) PKCollectionParser *exprToken;
@property (retain) PKParser *literal;
@property (retain) PKParser *number;
@property (retain) PKCollectionParser *operator;
@property (retain) PKCollectionParser *operatorName;
@property (retain) PKParser *multiplyOperator;
@property (retain) PKParser *functionName;
@property (retain) PKCollectionParser *variableReference;
@property (retain) PKCollectionParser *nameTest;
@property (retain) PKCollectionParser *nodeType;
@property (retain) PKCollectionParser *QName;
@end
