//
//  PredicateParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface TDNSPredicateBuilder : NSObject {
    NSString *defaultAttr;
    NSString *defaultRelation;
    NSString *defaultValue;
    PKToken *nonReservedWordFence;
    PKCollectionParser *exprParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *termParser;
    PKCollectionParser *andPrimaryExprParser;
    PKCollectionParser *primaryExprParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *negatedPredicateParser;
    PKCollectionParser *predicateParser;
    PKCollectionParser *completePredicateParser;
    PKCollectionParser *attrValuePredicateParser;
    PKCollectionParser *attrPredicateParser;
	PKCollectionParser *valuePredicateParser;
    PKCollectionParser *attrParser;
    PKCollectionParser *tagParser;
    PKCollectionParser *relationParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *boolParser;
    PKParser *trueParser;
    PKParser *falseParser;
    PKCollectionParser *stringParser;
    PKParser *quotedStringParser;
    PKCollectionParser *unquotedStringParser;
    PKCollectionParser *reservedWordParser;
    PKCollectionParser *nonReservedWordParser;
    PKPattern *reservedWordPattern;
    PKParser *numberParser;

}
- (NSPredicate *)buildFrom:(NSString *)s;

@property (nonatomic, copy) NSString *defaultAttr;
@property (nonatomic, copy) NSString *defaultRelation;
@property (nonatomic, copy) NSString *defaultValue;

@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *andPrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *negatedPredicateParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *completePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrValuePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrPredicateParser;
@property (nonatomic, retain) PKCollectionParser *valuePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrParser;
@property (nonatomic, retain) PKCollectionParser *tagParser;
@property (nonatomic, retain) PKCollectionParser *relationParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *boolParser;
@property (nonatomic, retain) PKParser *trueParser;
@property (nonatomic, retain) PKParser *falseParser;
@property (nonatomic, retain) PKCollectionParser *stringParser;
@property (nonatomic, retain) PKParser *quotedStringParser;
@property (nonatomic, retain) PKCollectionParser *unquotedStringParser;
@property (nonatomic, retain) PKCollectionParser *reservedWordParser;
@property (nonatomic, retain) PKCollectionParser *nonReservedWordParser;
@property (nonatomic, retain) PKPattern *reservedWordPattern;
@property (nonatomic, retain) PKParser *numberParser;
@end
