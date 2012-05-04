//
//  ObjectiveCStateTestsHelpers.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/28/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParser.h"
#import "TokensStream.h"
#import "Store.h"

typedef void(^GBStateMockBlock)(id parser, id tokens);

extern void runWithString(NSString *string, GBStateMockBlock handler);
extern void runWithFile(NSString *file, GBStateMockBlock handler);
