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

/** Returns the last character of the string.
 
 @return Returs the last character of the string.
 @exception NSRangeException Thrown if the string is empty.
 */
- (unichar)lastCharacter;

@end

#pragma mark -

@implementation NSString (GBString)

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
	NSArray *words = [self componentsSeparatedByRegex:@"\\s+"];
	[words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
		if ([word length] == 0) return;
		if ([result length] > 0) [result appendString:@" "];
		[result appendString:word];
	}];
	return result;
}

@end

#pragma mark -

@implementation NSString (GBPrivateAPI)

- (unichar)lastCharacter {
	return [self characterAtIndex:[self length] - 1];
}

@end

