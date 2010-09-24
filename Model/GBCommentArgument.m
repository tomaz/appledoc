//
//  GBCommentArgument.m
//  appledoc
//
//  Created by Tomaz Kragelj on 19.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBCommentParagraph.h"
#import "GBCommentArgument.h"

@implementation GBCommentArgument

#pragma mark Initialization & disposal

+ (id)argumentWithName:(NSString *)name description:(GBCommentParagraph *)description {
	NSParameterAssert(name != nil);
	NSParameterAssert([name length] > 0);
	NSParameterAssert(description != nil);
	GBCommentArgument *result = [self argument];
	result.argumentName = name;
	result.argumentDescription = description;
	return result;
}

+ (id)argument {
	GBCommentArgument *result = [[GBCommentArgument alloc] init];
	return result;
}

#pragma mark Overriden methods

- (NSString *)description {
	return self.argumentName;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"%@ %@{ %@ }", [self className], self.argumentName, self.argumentDescription];
}

#pragma mark Properties

@synthesize argumentName;
@synthesize argumentDescription;

@end
