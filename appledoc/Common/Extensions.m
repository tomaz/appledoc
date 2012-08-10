//
//  Extensions.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <objc/runtime.h>
#import "Extensions.h"

@implementation NSObject (Appledoc)

- (NSString *)gb_description {
	return [self debugDescription];
}

@end

#pragma mark -

@implementation NSError (GBError)

+ (NSError *)gb_errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason {
	NSMutableDictionary *info = nil;
	if ([description length] > 0 || [reason length] > 0) {
		info = [NSMutableDictionary dictionaryWithCapacity:2];
		if ([description length] > 0) info[NSLocalizedDescriptionKey] = description;
		if ([reason length] > 0) info[NSLocalizedFailureReasonErrorKey] = reason;
	}
	return [self errorWithDomain:@"appledoc" code:code userInfo:info];
}

@end

#pragma mark - 

@implementation NSFileManager (Appledoc)

- (BOOL)gb_fileExistsAndIsFileAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && !isDirectory);
}

- (BOOL)gb_fileExistsAndIsDirectoryAtPath:(NSString *)path {
	BOOL isDirectory = NO;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
	return (exists && isDirectory);
}
	
@end

#pragma mark - 

@implementation NSString (Appledoc)

+ (NSUInteger)gb_defaultDescriptionLength {
	return 35;
}

- (NSString *)gb_description {
	return [self gb_descriptionWithLength:[[self class] gb_defaultDescriptionLength]];
}

- (NSString *)gb_descriptionWithLength:(NSUInteger)length {
	static NSRegularExpression *regex = nil;
	if (!regex) regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];

	NSRange range = NSMakeRange(0, self.length);
	NSString *result = [regex stringByReplacingMatchesInString:self options:0 range:range withTemplate:@" "];
	result = [result gb_stringByTrimmingWhitespaceAndNewLine];
	if (result.length <= length) return result;
	
	NSUInteger extractLength = length / 2;
	NSString *prefix = [result substringToIndex:extractLength];
	NSString *suffix = [result substringFromIndex:result.length - extractLength];
	return [NSString stringWithFormat:@"%@…%@", prefix, suffix];
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

- (BOOL)gb_stringContainsOnlyCharactersFromSet:(NSCharacterSet *)set {
	for (NSUInteger i=0; i<self.length; i++) {
		unichar ch = [self characterAtIndex:i];
		if (![set characterIsMember:ch]) return NO;
	}
	return YES;
}

@end

#pragma mark - 

@implementation NSArray (Appledoc)

- (BOOL)gb_containsObjectWithValue:(id)value forSelector:(SEL)selector {
	NSUInteger index = [self gb_indexOfObjectWithValue:value forSelector:selector];
	return (index != NSNotFound);
}

- (NSUInteger)gb_indexOfObjectWithValue:(id)value forSelector:(SEL)selector {
	// Note that it's ok to ignore the warning here as long as the method corresponding to the given selector returns an object... See more here http://stackoverflow.com/questions/8855461/did-the-target-action-design-pattern-became-bad-practice-under-arc
	__block NSUInteger result = NSNotFound;
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {		
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		id objValue = [obj performSelector:selector];
#pragma clang diagnostic pop
		if ([objValue isEqual:value]) {
			result = idx;
			*stop = YES;
		}
	}];
	return result;
}

@end

#pragma mark - 

static const void *GBLocationKey = @"GBLocation";

@implementation PKToken (Appledoc)

- (BOOL)matches:(id)expected {
	NSUInteger result = [self matchResult:expected];
	return (result != NSNotFound);
}

- (NSUInteger)matchResult:(id)expected {
	// If expected is an array, allow if any of the objects matches. Otherwise we require exact match.
	if ([expected isKindOfClass:[NSArray class]]) {
		__block NSUInteger result = NSNotFound;
		[expected enumerateObjectsUsingBlock:^(NSString *expectedToken, NSUInteger idx, BOOL *stop) {
			if ([self.stringValue isEqual:expectedToken]) {
				result = idx;
				*stop = YES;
				return;
			}
		}];
		return result;
	} else {
		if ([self.stringValue isEqual:expected]) return 0;
	}
	return NSNotFound;
}

- (NSPoint)location {
	NSValue *storage = objc_getAssociatedObject(self, GBLocationKey);
	return [storage pointValue];
}
- (void)setLocation:(NSPoint)val {
	NSValue *storage = [NSValue valueWithPoint:val];
	objc_setAssociatedObject(self, GBLocationKey, storage, OBJC_ASSOCIATION_RETAIN);
}

@end