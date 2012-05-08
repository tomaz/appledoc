//
//  ObjectiveCParseData.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/4/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Extensions.h"
#import "Store.h"
#import "TokensStream.h"
#import "ObjectiveCParser.h"
#import "ObjectiveCParseData.h"

@interface ObjectiveCParseData ()
- (BOOL)isStringPrefixedWithDoubleUnderscore:(NSString *)string;
- (BOOL)isStringPrefixedWithUnderscore:(NSString *)string;
- (BOOL)isStringPrefixedWithDigit:(NSString *)string;
- (BOOL)isStringComposedOfUppercaseLetters:(NSString *)string;
@property (nonatomic, readwrite, strong) Store *store;
@property (nonatomic, readwrite, strong) TokensStream *stream;
@property (nonatomic, readwrite, strong) ObjectiveCParser *parser;
@property (nonatomic, strong) NSCharacterSet *uppercaseLettersSet;
@end

#pragma mark - 

@implementation ObjectiveCParseData

@synthesize store = _store;
@synthesize stream = _stream;
@synthesize parser = _parser;
@synthesize uppercaseLettersSet = _uppercaseLettersSet;

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

- (NSUInteger)lookaheadIndexOfFirstToken:(id)end {
	__block NSUInteger result = NSNotFound;
	[self.stream lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		if ([token matches:end]) {
			*stop = YES;
			result = lookahead;
			return;
		}
	}];
	return result;
}

- (NSUInteger)lookaheadIndexOfFirstPotentialDescriptorWithEndDelimiters:(id)end block:(GBDescriptorsLookaheadBlock)handler {
	__block NSUInteger result = NSNotFound;
	[self.stream lookAheadWithBlock:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		if ([token matches:end]) {
			*stop = YES;
			return;
		}
		
		BOOL isDescriptor = NO;
		handler(token, lookahead, &isDescriptor);
		if (isDescriptor) {
			result = lookahead;
			*stop = YES;
			return;
		}
	}];
	return result;
}

- (BOOL)doesStringLookLikeDescriptor:(NSString *)string {
	if ([self isStringPrefixedWithDoubleUnderscore:string]) return YES;
	if ([self isStringPrefixedWithUnderscore:string]) return NO;
	if ([self isStringPrefixedWithDigit:string]) return NO;
	if ([self isStringComposedOfUppercaseLetters:string]) return YES;
	return NO;
}

- (BOOL)isStringPrefixedWithDoubleUnderscore:(NSString *)string {
	if ([string hasPrefix:@"__"]) return YES;
	return NO;
}

- (BOOL)isStringPrefixedWithUnderscore:(NSString *)string {
	if ([string hasPrefix:@"_"]) return YES;
	return NO;
}

- (BOOL)isStringPrefixedWithDigit:(NSString *)string {
	NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
	NSRange digitRange = [string rangeOfCharacterFromSet:digitSet];
	if (digitRange.location == 0 && digitRange.length > 0) return YES;
	return NO;
}

- (BOOL)isStringComposedOfUppercaseLetters:(NSString *)string {
	NSCharacterSet *allowedCharacters = self.uppercaseLettersSet;
	return [string gb_stringContainsOnlyCharactersFromSet:allowedCharacters];
}

#pragma mark - Properties

- (NSCharacterSet *)uppercaseLettersSet {
	if (_uppercaseLettersSet) return _uppercaseLettersSet;
	_uppercaseLettersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
	return _uppercaseLettersSet;
}

@end
