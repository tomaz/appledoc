//
//  PKXmlTokenAssembly.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/21/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKAssembly.h>

@class TDXmlTokenizer;

@interface TDXmlTokenAssembly : PKAssembly <NSCopying> {
    TDXmlTokenizer *tokenizer;
    NSMutableArray *tokens;
}
@property (nonatomic, retain) TDXmlTokenizer *tokenizer;
@end
