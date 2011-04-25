//
//  PKMiniCSSAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/23/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKToken;

@interface TDMiniCSSAssembler : NSObject {
    NSMutableDictionary *attributes;
    PKToken *paren;
    PKToken *curly;
}
@property (nonatomic, retain) NSMutableDictionary *attributes;
@property (nonatomic, retain) PKToken *paren;
@property (nonatomic, retain) PKToken *curly;
@end
