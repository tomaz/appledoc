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
- (BOOL)isStringPrefixedWithDoubleUnderscore:(NSString *)string;
- (BOOL)isStringPrefixedWithDigit:(NSString *)string;
- (BOOL)isStringUppercase:(NSString *)string;
@property (nonatomic, readwrite, strong) Store *store;
@property (nonatomic, readwrite, strong) TokensStream *stream;
@property (nonatomic, readwrite, strong) ObjectiveCParser *parser;
@end

#pragma mark - 

@implementation ObjectiveCParseData

@synthesize store = _store;
@synthesize stream = _stream;
@synthesize parser = _parser;

#pragma mark - Initialization & disposal

+ (id)dataWithStream:(TokensStream *)stream parser:(ObjectiveCParser *)parser store:(Store *)store {
	ObjectiveCParseData *result = [[ObjectiveCParseData alloc] init];
	if (result) {
		result.stream = stream;
		result.parser = parser;
		result.store = store;
	}
	return result;
}

#pragma mark - Helper methods

- (BOOL)doesStringLookLikeDescriptor:(NSString *)string {
	if ([self isStringPrefixedWithDoubleUnderscore:string]) return YES;
	if ([self isStringPrefixedWithDigit:string]) return NO;
	if ([self isStringUppercase:string]) return YES;
	return NO;
}

- (BOOL)isStringPrefixedWithDoubleUnderscore:(NSString *)string {
	if ([string hasPrefix:@"__"]) return YES;
	return NO;
}

- (BOOL)isStringPrefixedWithDigit:(NSString *)string {
	NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
	NSRange digitRange = [string rangeOfCharacterFromSet:digitSet];
	if (digitRange.location == 0 && digitRange.length > 0) return YES;
	return NO;
}

- (BOOL)isStringUppercase:(NSString *)string {
	// Not very efficient and possibly wrong if used for localized strings, but seems to work for our purpose...
	NSString *uppercase = [string uppercaseString];
	if ([uppercase isEqualToString:string]) return YES;
	return NO;
}

@end
