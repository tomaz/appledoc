//
//  FetchDocumentationTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 10.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "FetchDocumentationTask.h"

@implementation FetchDocumentationTask

- (GBResult)runTask {
	LogDebug(@"Copying documentation from other objects...");
	return GBResultOk;
}

@end
