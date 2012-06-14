//
//  CommentParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 6/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentParser.h"

@interface CommentParser ()
- (void)parseSingleLinerFromString:(NSString *)string line:(NSUInteger)line;
- (void)parseMultiLinerFromString:(NSString *)string line:(NSUInteger)line;
- (BOOL)isSingleLiner:(NSString *)string;
- (BOOL)isMultiLiner:(NSString *)string;
- (BOOL)isInliner:(NSString *)string;
- (BOOL)isMethodGroup:(NSString *)string;
- (NSString *)trimmedGroupName:(NSString *)line;
- (NSString *)trimmedInlineLine:(NSString *)line;
- (NSString *)trimmedCommentLine:(NSString *)line;
@property (nonatomic, strong, readwrite) NSString *groupComment;
@property (nonatomic, strong, readwrite) NSString *comment;
@property (nonatomic, assign, readwrite) BOOL isCommentInline;
@property (nonatomic, assign) NSUInteger lastSingleLinerLine;
@end

@implementation CommentParser

@synthesize groupComment = _groupComment;
@synthesize comment = _comment;
@synthesize isCommentInline = _isCommentInline;
@synthesize lastSingleLinerLine = _lastSingleLinerLine;

#pragma mark - Parsing

- (BOOL)isAppledocComment:(NSString *)comment {
	if ([self isSingleLiner:comment]) return YES;
	if ([self isMultiLiner:comment]) return YES;
	return NO;
}

- (void)parseComment:(NSString *)comment line:(NSUInteger)line {
	if ([self isSingleLiner:comment]) {
		LogParDebug(@"Parsing single line comment '%@' at %lu...", [comment gb_description], line);
		[self parseSingleLinerFromString:comment line:line];
	} else if ([self isMultiLiner:comment]) {
		LogParDebug(@"Parsing multi line comment '%@' at %lu...", [comment gb_description], line);
		[self parseMultiLinerFromString:comment line:line];
	} else {
		LogWarn(@"Invalid comment '%@' at line %lu!", [comment gb_description], line);
	}
}

- (void)reset {
	self.groupComment = nil;
	self.comment = nil;
	self.isCommentInline = NO;
}

#pragma mark - Helper methods

- (void)parseSingleLinerFromString:(NSString *)string line:(NSUInteger)line {
	BOOL isContinuation = (self.comment != nil) && (line == self.lastSingleLinerLine + 1);
	NSString *text = [string substringFromIndex:3];
	text = [self trimmedCommentLine:text];
	if (isContinuation) {
		if (self.isCommentInline && [self isInliner:text]) {
			text = [self trimmedInlineLine:text];
		}
		self.comment = [self.comment stringByAppendingFormat:@"\n%@", text];
	} else {
		if ([self isMethodGroup:text]) {
			self.groupComment = [self trimmedGroupName:text];
		} else if ([self isInliner:text]) {
			self.comment = [self trimmedInlineLine:text];
			self.isCommentInline = YES;
		} else {
			self.comment = text;
		}
	}
	self.lastSingleLinerLine = line;
}

- (void)parseMultiLinerFromString:(NSString *)string line:(NSUInteger)line {
	NSUInteger location = [string gb_indexOfString:@"*/"];
	if (location == NSNotFound) {
		LogWarn(@"Multi line comment '%@' at %lu is missing comment end!", [string gb_description], line);
		return;
	}
	
	__weak CommentParser *blockSelf = self;
	__block NSUInteger commentLine = 1;
	NSRange range = NSMakeRange(3, location - 3);
	NSString *text = [string substringWithRange:range];
	NSMutableString *result = [NSMutableString stringWithCapacity:text.length];
	[text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		NSString *clean = [self trimmedCommentLine:line];
		if (commentLine == 1) {
			if ([self isMethodGroup:clean]) {
				blockSelf.groupComment = [blockSelf trimmedGroupName:clean];
				return;
			}
			if ([self isInliner:clean]) self.isCommentInline = YES;
		}
		if (self.isCommentInline && [self isInliner:clean]) clean = [self trimmedInlineLine:clean];
		if (result.length > 0) [result appendString:@"\n"];
		[result appendString:clean];
		commentLine++;
	}];
	
	self.comment = (result.length > 0) ? result : nil;
}

- (BOOL)isSingleLiner:(NSString *)string {
	if ([string hasPrefix:@"///"]) return YES;
	return NO;
}

- (BOOL)isMultiLiner:(NSString *)string {
	if ([string hasPrefix:@"/**"]) return YES;
	return NO;
}

- (BOOL)isInliner:(NSString *)string {
	if ([string hasPrefix:@"<"]) return YES;
	return NO;
}

- (BOOL)isMethodGroup:(NSString *)string {
	string = [string gb_stringByTrimmingWhitespaceAndNewLine];
	if ([string hasPrefix:@"@name"] && string.length > 6) return YES;
	return NO;
}

- (NSString *)trimmedGroupName:(NSString *)line {
	line = [line gb_stringByTrimmingWhitespaceAndNewLine];
	line = [line gb_stringByReplacingWhitespaceWithSpaces];
	line = [line substringFromIndex:6];
	return line;
}

- (NSString *)trimmedInlineLine:(NSString *)line {
	line = [line substringFromIndex:1];
	line = [self trimmedCommentLine:line];
	return line;
}

- (NSString *)trimmedCommentLine:(NSString *)line {
	if ([line hasPrefix:@" "]) return [line substringFromIndex:1];
	return line;
}

@end
