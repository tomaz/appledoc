//
//  ObjectiveCParseData.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/4/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "TokensStream.h"
#import "ObjectiveCParser.h"
#import "ObjectiveCParseData.h"

@interface ObjectiveCParseData ()
@property (nonatomic, readwrite, strong) Store *store;
@property (nonatomic, readwrite, strong) TokensStream *stream;
@property (nonatomic, readwrite, strong) ObjectiveCParser *parser;
@end

#pragma mark - 

@implementation ObjectiveCParseData

@synthesize store = _store;
@synthesize stream = _stream;
@synthesize parser = _parser;

#pragma mark -  Initialization & disposal

+ (id)dataWithStream:(TokensStream *)stream parser:(ObjectiveCParser *)parser store:(Store *)store {
	ObjectiveCParseData *result = [[ObjectiveCParseData alloc] init];
	if (result) {
		result.stream = stream;
		result.parser = parser;
		result.store = store;
	}
	return result;
}

@end
