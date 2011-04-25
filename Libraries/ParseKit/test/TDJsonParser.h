//
//  PKJsonParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/18/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface TDJsonParser : PKAlternation {
    BOOL shouldAssemble;
    PKParser *stringParser;
    PKParser *numberParser;
    PKParser *nullParser;
    PKCollectionParser *booleanParser;
    PKCollectionParser *arrayParser;
    PKCollectionParser *objectParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *commaValueParser;
    PKCollectionParser *propertyParser;
    PKCollectionParser *commaPropertyParser;
    
    PKToken *curly;
    PKToken *bracket;
}

- (id)initWithIntentToAssemble:(BOOL)shouldAssemble;

- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKParser *stringParser;
@property (nonatomic, retain) PKParser *numberParser;
@property (nonatomic, retain) PKParser *nullParser;
@property (nonatomic, retain) PKCollectionParser *booleanParser;
@property (nonatomic, retain) PKCollectionParser *arrayParser;
@property (nonatomic, retain) PKCollectionParser *objectParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *commaValueParser;
@property (nonatomic, retain) PKCollectionParser *propertyParser;
@property (nonatomic, retain) PKCollectionParser *commaPropertyParser;
@end