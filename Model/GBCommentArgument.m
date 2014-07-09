//
//  GBCommentArgument.m
//  appledoc
//
//  Created by Tomaz Kragelj on 16.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import "GBSourceInfo.h"
#import "GBCommentComponentsList.h"
#import "GBCommentArgument.h"

@implementation GBCommentArgument

#pragma mark Initialization & disposal

+ (id)argumentWithName:(NSString *)name {
	return [self argumentWithName:name sourceInfo:nil];
}

+ (id)argumentWithName:(NSString *)name sourceInfo:(GBSourceInfo *)info {
	GBCommentArgument *result = [[self alloc] init];
	if (result) {
		result.argumentName = name;
		result.sourceInfo = info;
	}
	return result;
}

- (id)init {
    self = [super init];
    if (self) {
		self.argumentDescription = [GBCommentComponentsList componentsList];
    }    
    return self;
}

#pragma mark Properties

@synthesize argumentName;
@synthesize argumentDescription;
@synthesize sourceInfo;

@end
