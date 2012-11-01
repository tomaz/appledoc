//
//  PKToken+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface PKToken (Appledoc)

- (BOOL)matches:(id)expected;
- (NSUInteger)matchResult:(id)expected;
@property (nonatomic, assign) NSPoint location;

@end
