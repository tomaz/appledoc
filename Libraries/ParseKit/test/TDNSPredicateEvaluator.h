//
//  PKNSPredicateEvaluator.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/ParseKit.h>

@class TDNSPredicateEvaluator;

@protocol TDKeyPathResolver <NSObject>
- (id)resolvedValueForKeyPath:(NSString *)s;
@end

@interface TDNSPredicateEvaluator : NSObject {
    id <TDKeyPathResolver>resolver;
    PKParser *parser;
    PKToken *openCurly;
}
- (id)initWithKeyPathResolver:(id <TDKeyPathResolver>)r;

- (BOOL)evaluate:(NSString *)s;

@property (nonatomic, retain) PKParser *parser;
@end
