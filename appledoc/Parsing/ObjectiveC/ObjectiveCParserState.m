//
//  ObjectiveCParserState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParserState.h"

@implementation ObjectiveCParserState

#pragma mark - Parsing entry point

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	return GBResultOk;
}

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	ObjectiveCParseData *data = [ObjectiveCParseData dataWithStream:stream parser:parser store:store];
	return [self parseWithData:data];
}

@end
