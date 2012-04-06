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

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store {
	return GBResultOk;
}

@end
