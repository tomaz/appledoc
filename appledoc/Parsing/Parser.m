//
//  Parser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "Parser.h"

typedef void(^ParserPathBlock)(NSString *path);

#pragma mark - 

@interface Parser ()
- (void)parsePath:(NSString *)path withBlock:(ParserPathBlock)handler;
@end

#pragma mark -

@implementation Parser

#pragma mark - Task invocation

- (NSInteger)runTask {
	LogNormal(@"Starting parsing...");
	LogInfo(@"Parsing finished.");
	return 0;
}

#pragma mark - Parsing helpers

- (void)parsePath:(NSString *)path withBlock:(ParserPathBlock)handler {
}

@end
