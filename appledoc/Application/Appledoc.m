//
//  Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "Parser.h"
#import "Appledoc.h"

@implementation Appledoc

#pragma mark - Running

- (NSInteger)runWithSettings:(GBSettings *)settings {
	LogNormal(@"Starting appledoc...");
	GBResult result = GBResultOk;
	
	result = [self.parser runWithSettings:settings store:self.store];
	if (result != GBResultOk) {
		LogError(@"Parsing finished with error code %ld, exiting!", result);
		return result;
	}
	
	LogInfo(@"Appledoc finished.");
	return result;
}

#pragma mark - Properties

- (Store *)store {
	if (_store) return _store;
	LogIntDebug(@"Initializing store due to first access...");
	_store = [[Store alloc] init];
	return _store;
}

- (Parser *)parser {
	if (_parser) return _parser;
	LogIntDebug(@"Initializing parser due to first access...");
	_parser = [[Parser alloc] init];
	return _parser;
}

@end
