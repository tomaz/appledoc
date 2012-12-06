//
//  ProcessorCommentTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 6.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "ObjectInfoBase.h"
#import "ProcessorCommentTask.h"

@interface ProcessorCommentTask ()
@property (nonatomic, strong) ObjectInfoBase *processingObject;
@property (nonatomic, strong) ObjectInfoBase *processingContext;
@end

#pragma mark -

@implementation ProcessorCommentTask

#pragma mark - Processing

- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)context {
	if (!object.comment || !object.comment.sourceString) return GBResultOk;
	self.processingObject = object;
	self.processingContext = context;
	return [self processComment:object.comment];
}

#pragma mark - Helper methods

- (BOOL)isStringCodeBlock:(NSString *)string {
	if (string.length == 0) return NO;
	
	// Is fenced code block?
	if ([string hasPrefix:@"```"] && [string hasSuffix:@"```"]) return YES;
	
	// Is tab/four space prefixed code block?
	__block BOOL result = YES;
	[string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		if ([line hasPrefix:@"\t"] || [line hasPrefix:@"    "]) return;
		result = NO;
		*stop = YES;
	}];
	return result;
}

@end
