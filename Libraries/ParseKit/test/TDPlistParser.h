//
//  PKPlistParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/9/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface TDPlistParser : PKAlternation {
    PKCollectionParser *dictParser;
    PKCollectionParser *keyValuePairParser;
    PKCollectionParser *arrayParser;
    PKCollectionParser *commaValueParser;
    PKCollectionParser *keyParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *stringParser;
    PKParser *numParser;
    PKParser *nullParser;
    PKToken *curly;
    PKToken *paren;
}
- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *dictParser;
@property (nonatomic, retain) PKCollectionParser *keyValuePairParser;
@property (nonatomic, retain) PKCollectionParser *arrayParser;
@property (nonatomic, retain) PKCollectionParser *commaValueParser;
@property (nonatomic, retain) PKCollectionParser *keyParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *stringParser;
@property (nonatomic, retain) PKParser *numParser;
@property (nonatomic, retain) PKParser *nullParser;
@end
