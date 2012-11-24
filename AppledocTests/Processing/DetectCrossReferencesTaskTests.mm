//
//  DetectCrossReferencesTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 24/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "DetectCrossReferencesTask.h"
#import "TestCaseBase.hh"

static void runWithTask(void(^handler)(DetectCrossReferencesTask *task, id comment)) {
	DetectCrossReferencesTask *task = [[DetectCrossReferencesTask alloc] init];
	CommentInfo *comment = [[CommentInfo alloc] init];
	handler(task, comment);
	[task release];
}

static void setupComment(id comment, NSString *first ...) {
	va_list args;
	va_start(args, first);
	NSMutableArray *sections = [@[] mutableCopy];
	for (NSString *arg=first; arg!=nil; arg=va_arg(args, NSString *)) {
		[sections addObject:arg];
	}
	va_end(args);
	
	if ([comment isKindOfClass:[CommentInfo class]])
		[comment setSourceSections:sections];
	else
		[given([comment sourceSections]) willReturn:sections];
}

#pragma mark -

TEST_BEGIN(DetectCrossReferencesTaskTests)

TEST_END
