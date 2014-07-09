//
//  GBComment.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBComment.h"

@implementation GBComment

#pragma mark Initialization & disposal

+ (id)commentWithStringValue:(NSString *)value {
	return [self commentWithStringValue:value sourceInfo:nil];
}

+ (id)commentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info {
	GBComment *result = [[self alloc] init];
	result.stringValue = value;
	result.sourceInfo = info;
	return result;
}

- (id)init {
	self = [super init];
	if (self) {
		self.longDescription = [GBCommentComponentsList componentsList];
		self.relatedItems = [GBCommentComponentsList componentsList];
		self.methodParameters = [NSMutableArray array];
		self.methodExceptions = [NSMutableArray array];
		self.methodResult = [GBCommentComponentsList componentsList];
		self.availability = [GBCommentComponentsList componentsList];
	}
	return self;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [NSString stringWithFormat:@"Comment '%@'", [self.stringValue normalizedDescription]];
}

- (NSString *)debugDescription {
	return [self description];
}

#pragma mark Properties

- (BOOL)hasShortDescription {
	return self.shortDescription != nil;
}

- (BOOL)hasLongDescription {
	return [self.longDescription.components count] > 0;
}

- (BOOL)hasMethodParameters {
	return [self.methodParameters count] > 0;
}

- (BOOL)hasMethodExceptions {
	return [self.methodExceptions count] > 0;
}

- (BOOL)hasMethodResult {
	return [self.methodResult.components count] > 0;
}

- (BOOL)hasRelatedItems {
	return [self.relatedItems.components count] > 0;
}

- (BOOL)hasAvailability {
	return [self.availability.components count] > 0;
}

- (BOOL)isCopied {
	return (self.originalContext != nil);
}

@synthesize originalContext;
@synthesize isProcessed;
@synthesize sourceInfo;
@synthesize stringValue;

@synthesize shortDescription;
@synthesize longDescription;
@synthesize relatedItems;

@synthesize methodParameters;
@synthesize methodExceptions;
@synthesize methodResult;
@synthesize availability;

@end
