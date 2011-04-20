//
//  PKArithmeticParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface TDArithmeticParser : PKSequence {
    PKCollectionParser *exprParser;
    PKCollectionParser *termParser;
    PKCollectionParser *plusTermParser;
    PKCollectionParser *minusTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *timesFactorParser;
    PKCollectionParser *divFactorParser;
    PKCollectionParser *exponentFactorParser;
    PKCollectionParser *phraseParser;
}
- (double)parse:(NSString *)s;

@property (retain) PKCollectionParser *exprParser;
@property (retain) PKCollectionParser *termParser;
@property (retain) PKCollectionParser *plusTermParser;
@property (retain) PKCollectionParser *minusTermParser;
@property (retain) PKCollectionParser *factorParser;
@property (retain) PKCollectionParser *timesFactorParser;
@property (retain) PKCollectionParser *divFactorParser;
@property (retain) PKCollectionParser *exponentFactorParser;
@property (retain) PKCollectionParser *phraseParser;
@end
