//
//  EnumItemInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "EnumItemInfo.h"

@implementation EnumItemInfo
@end

#pragma mark - 

@implementation EnumItemInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	if (self.itemName) [result appendString:self.itemName];
	if (self.itemValue) [result appendFormat:@" = %@", self.itemValue];
	return result;
}

@end
