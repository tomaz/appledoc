//
//  NSString+GBString.m
//  appledoc
//
//  Created by Tomaz Kragelj on 31.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "RegexKitLite.h"
#import "NSString+GBString.h"

@interface NSString (GBPrivateAPI)

- (unichar)lastCharacter;
- (NSArray *)arrayOfWords;

@end

#pragma mark -

@implementation NSString (GBString)

#pragma mark Simplifying string

- (NSString *)stringByTrimmingCharactersInSetFromEnd:(NSCharacterSet *)set {
	NSParameterAssert(set != nil);
	NSMutableString *result = [self mutableCopy];
	while ([result length] > 0 && [set characterIsMember:[result lastCharacter]]) {
		[result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
	}
	return result;
}

- (NSString *)stringByWordifyingWithSpaces {
	if ([self length] == 0) return self;
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	NSArray *words = [self arrayOfWords];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		if ([result length] > 0) [result appendString:@" "];
		[result appendString:word];
	}];
	return result;
}

- (NSString *)stringByTrimmingWhitespace {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingWhitespaceAndNewLine {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark Preparing nice descriptions

- (NSString *)normalizedDescription {
	return [self normalizedDescriptionWithMaxLength:[[self class] defaultNormalizedDescriptionLength]];
}

- (NSString *)normalizedDescriptionWithMaxLength:(NSUInteger)length {
	NSString *extract = [self stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
	if ([extract length] <= length) return [extract stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSArray *words = [extract arrayOfWords];
	length /= 2;
	
	NSMutableString *prefix = [NSMutableString stringWithCapacity:[extract length] / 2];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([prefix length] > 0) [prefix appendString:@" "];
		[prefix appendString:word];
		if ([prefix length] >= length) *stop = YES;
	}];
	
	NSMutableString *suffix = [NSMutableString stringWithCapacity:[prefix length]];
	[words enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([suffix length] > 0) [suffix insertString:@" " atIndex:0];
		[suffix insertString:word atIndex:0];
		if ([suffix length] >= length) *stop = YES;
	}];
	
	// Make sure we strip long words; note that we're casting to NSMutableString to prevent compiler warnings; although not good coding practice, it's safe in this case...
	if ([prefix length] > length) prefix = (NSMutableString *)[prefix substringToIndex:length];
	if ([suffix length] > length) suffix = (NSMutableString *)[suffix substringToIndex:length];
	
	return [NSString stringWithFormat:@"%@…%@", prefix, suffix];
}

+ (NSUInteger)defaultNormalizedDescriptionLength {
	return 35;
}

#pragma mark Getting information

+ (NSString *)stringByCombiningLines:(NSArray *)lines delimitWith:(NSString *)delimiter {
	NSMutableString *result = [NSMutableString string];
	if (!delimiter) delimiter = @"";
	[lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
		if ([result length] > 0) [result appendString:delimiter];
		[result appendString:line];
	}];
	return result;
}

- (NSArray *)arrayOfLines {
	// Although we could use regex here, this gives us nicer results (strips all newlines for example), taken straight from Apple String Programming Guide.
	NSMutableArray *result = [NSMutableArray array];
	NSUInteger length = [self length];
	NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
	NSRange currentRange;
	while (paraEnd < length) {
		[self getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
		currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
		[result addObject:[self substringWithRange:currentRange]];
	}
	return result;
}

- (NSUInteger)numberOfLines {
	if ([self length] == 0) return 0;
	return [self numberOfLinesInRange:NSMakeRange(0, [self length])];
}

- (NSUInteger)numberOfLinesInRange:(NSRange)range {
	NSString *substring = [self substringWithRange:range];
	NSArray *lines = [substring componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	return [lines count];
}

@end

#pragma mark -

@implementation NSString (GBPrivateAPI)

- (unichar)lastCharacter {
	return [self characterAtIndex:[self length] - 1];
}

- (NSArray *)arrayOfWords {
	return [self componentsSeparatedByRegex:@"\\s+"];
}

@end

