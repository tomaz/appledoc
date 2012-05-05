//
//  ObjectiveCParseData.h
//  appledoc
//
//  Created by Tomaž Kragelj on 5/4/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class Store;
@class TokensStream;
@class ObjectiveCParser;

/** Provides data to ObjectiveCParserState objects.
 
 The main reason for introducing this object is to reduce the number of parameters otherwise required for states. Instead of passing individual parameters around, we're now using parameter object.
 */
@interface ObjectiveCParseData : NSObject

+ (id)dataWithStream:(TokensStream *)stream parser:(ObjectiveCParser *)parser store:(Store *)store;

- (BOOL)doesStringLookLikeDescriptor:(NSString *)string;

@property (nonatomic, readonly, strong) Store *store;
@property (nonatomic, readonly, strong) TokensStream *stream;
@property (nonatomic, readonly, strong) ObjectiveCParser *parser;

@end
