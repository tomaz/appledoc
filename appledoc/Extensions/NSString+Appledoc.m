//
//  NSString+Appledoc.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "NSString+Appledoc.h"

@implementation NSString (Appledoc)

+ (NSString *)gb_format:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	return result;
}

+ (NSUInteger)gb_defaultDescriptionLength {
	return 35;
}

- (NSString *)gb_description {
	return [self gb_descriptionWithLength:[[self class] gb_defaultDescriptionLength]];
}

- (NSString *)gb_descriptionWithLength:(NSUInteger)length {
	NSRange range = NSMakeRange(0, self.length);
	NSStringEnumerationOptions options = NSStringEnumerationByWords;
	NSMutableString *result = [NSMutableString stringWithCapacity:length];
	[self enumerateSubstringsInRange:range options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if (result.length > 0) [result appendString:@" "];
		[result appendString:substring];
		if (result.length > length) {
			[result appendString:@"…"];
			*stop = YES;
		}
	}];
	return result;
}

- (NSString *)gb_stringByStandardizingCurrentDir {
	// Converts . to actual working directory.
	if (![self hasPrefix:@"."] || [self hasPrefix:@".."]) return self;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *suffix = [self substringFromIndex:1];
	NSString *currentDir = [manager currentDirectoryPath];
	return [currentDir stringByAppendingPathComponent:suffix];
}

- (NSString *)gb_stringByStandardizingCurrentDirAndPath {
	NSString *result = [self gb_stringByStandardizingCurrentDir];
	result = [result stringByStandardizingPath];
	return result;
}

- (NSString *)gb_stringByReplacingWhitespaceWithSpaces {
	return [self gb_descriptionWithLength:self.length];
}

- (NSString *)gb_stringByReplacing:(NSDictionary *)info {
	__block NSString *result = self;
	[info enumerateKeysAndObjectsUsingBlock:^(NSString *find, NSString *replace, BOOL *stop) {
		result = [result stringByReplacingOccurrencesOfString:find withString:replace];
	}];
	return result;
}

- (NSString *)gb_stringByTrimmingNewLines {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSString *)gb_stringByTrimmingWhitespaceAndNewLine {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSUInteger)gb_indexOfString:(NSString *)string {
	NSRange range = [self rangeOfString:string];
	return range.location;
}

- (NSRange)gb_range {
	return NSMakeRange(0, self.length);
}

- (BOOL)gb_contains:(NSString *)string {
	return ([self rangeOfString:string].location != NSNotFound);
}

- (BOOL)gb_stringContainsOnlyWhitespace {
	return [self gb_stringContainsOnlyCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)gb_stringContainsOnlyCharactersFromSet:(NSCharacterSet *)set {
	for (NSUInteger i=0; i<self.length; i++) {
		unichar ch = [self characterAtIndex:i];
		if (![set characterIsMember:ch]) return NO;
	}
	return YES;
}

@end
