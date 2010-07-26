//
//  PKToken+GBToken.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "PKToken+GBToken.h"

@implementation PKToken (GBToken)

- (BOOL)matches:(NSString *)string {
	return [[self stringValue] isEqualToString:string];
}

- (BOOL)contains:(NSString *)string {
	return ([[self stringValue] rangeOfString:string].location != NSNotFound);
}

@end
