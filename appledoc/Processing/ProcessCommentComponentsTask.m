//
//  ProcessCommentComponentsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "CommentComponentInfo.h"
#import "ProcessCommentComponentsTask.h"

@implementation ProcessCommentComponentsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogProInfo(@"Processing comment %@ for components...");
	return GBResultOk;
}

#pragma mark - Low level string parsing

- (CommentComponentInfo *)componentInfoFromString:(NSString *)string {
	LogProDebug(@"Creating component for %@...", [string gb_description]);
	CommentComponentInfo *result = [[CommentComponentInfo alloc] init];
	result.componentSourceString = string;
	return result;
}

@end
