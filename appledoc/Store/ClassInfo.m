//
//  ClassInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ClassInfo.h"

@implementation ClassInfo

@synthesize nameOfClass;
@synthesize nameOfSuperClass;

@end

#pragma mark - 

@implementation ClassInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	[result appendFormat:@"@interface %@", self.nameOfClass];
	if (self.nameOfSuperClass) [result appendFormat:@" : %@", self.nameOfSuperClass];
	[result appendString:[super description]];
	return result;
}

@end
