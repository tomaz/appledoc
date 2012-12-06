//
//  ProcessorTaskTests.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/25/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "ProcessorTask.h"
#import "TestCaseBase.hh"

static void runWithTask(void(^handler)(ProcessorTask *task)) {
	ProcessorTask *task = [[ProcessorTask alloc] init];
	handler(task);
	[task release];
}

#pragma mark -

TEST_BEGIN(ProcessorTaskTests)

TEST_END