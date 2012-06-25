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
@property (nonatomic, strong) NSString *groupComment;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) BOOL isCommentInline;
@property (nonatomic, assign) NSUInteger lastSingleLinerLine;
@end

@interface CommentParser (ParsingHelpers)
- (void)parseSingleLinerFromString:(NSString *)string line:(NSUInteger)line;
- (void)parseMultiLinerFromString:(NSString *)string line:(NSUInteger)line;
- (void)startGroupWithText:(NSString *)text;
- (void)startCommentWithText:(NSString *)text isInline:(BOOL)isInline;
- (void)continueCommentWithText:(NSString *)text isInline:(BOOL)isInline;
- (void)notifyAboutGroupIfNecessaryAndReset:(BOOL)reset;
- (void)notifyAboutCommentIfNecessaryAndReset:(BOOL)reset;
@end

@interface CommentParser (CommentTextHandling)
- (NSString *)trimmedGroupName:(NSString *)line;
- (NSString *)trimmedInlineLine:(NSString *)line;
- (NSString *)trimmedCommentLine:(NSString *)line;
@end

@interface CommentParser (DeterminingCommentKind)
- (BOOL)isSingleLiner:(NSString *)string;
- (BOOL)isMultiLiner:(NSString *)string;
- (BOOL)isInliner:(NSString *)string;
- (BOOL)isMethodGroup:(NSString *)string;
@end

#pragma mark -

@implementation CommentParser

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

- (void)notifyAndReset {
	LogParDebug(@"Resetting internal comment data...");
	[self notifyAboutGroupIfNecessaryAndReset:YES];
	[self notifyAboutCommentIfNecessaryAndReset:YES];
}

@end

#pragma mark - 

@implementation CommentParser (ParsingHelpers)

- (void)parseSingleLinerFromString:(NSString *)string line:(NSUInteger)line {
	BOOL isContinuation = (self.comment != nil) && (line == self.lastSingleLinerLine + 1);
	NSString *text = [string substringFromIndex:3];
	text = [self trimmedCommentLine:text];
	if (isContinuation) {
		BOOL isInline = (self.isCommentInline && [self isInliner:text]);
		[self continueCommentWithText:text isInline:isInline];
	} else {
		[self notifyAboutCommentIfNecessaryAndReset:YES];
		if ([self isMethodGroup:text]) {
			[self startGroupWithText:text];
			[self notifyAboutGroupIfNecessaryAndReset:YES];
		} else {
			BOOL isInline = [self isInliner:text];
			[self startCommentWithText:text isInline:isInline];
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
	
	[self notifyAboutCommentIfNecessaryAndReset:YES];

	__weak CommentParser *blockSelf = self;
	__block NSUInteger commentLine = 1;
	__block BOOL isInline = NO;
	NSRange range = NSMakeRange(3, location - 3);
	NSString *text = [string substringWithRange:range];
	[text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		NSString *clean = [blockSelf trimmedCommentLine:line];
		if (commentLine == 1) {
			if ([self isMethodGroup:clean]) {
				[blockSelf startGroupWithText:clean];
				[blockSelf notifyAboutGroupIfNecessaryAndReset:YES];
			} else if (clean.length > 0) {
				if ([blockSelf isInliner:clean]) isInline = YES;
				[blockSelf startCommentWithText:clean isInline:isInline];
				commentLine++;
			}
			return;
		}
		BOOL isLineInline = (isInline && [blockSelf isInliner:clean]);
		[blockSelf continueCommentWithText:clean isInline:isLineInline];
		commentLine++;
	}];

	if (self.comment.length == 0) self.comment = nil;
	[self notifyAboutCommentIfNecessaryAndReset:YES];
}

- (void)startGroupWithText:(NSString *)text {
	self.groupComment = [self trimmedGroupName:text];
}

- (void)startCommentWithText:(NSString *)text isInline:(BOOL)isInline {
	if (isInline) text = [self trimmedInlineLine:text];
	self.comment = text;
	self.isCommentInline = isInline;
}

- (void)continueCommentWithText:(NSString *)text isInline:(BOOL)isInline {
	if (isInline) text = [self trimmedInlineLine:text];
	self.comment = [self.comment stringByAppendingFormat:@"\n%@", text];
}

- (void)notifyAboutGroupIfNecessaryAndReset:(BOOL)reset {
	if (!self.groupComment) return;
	if (self.groupRegistrator) {
		LogParDebug(@"Notifying about group comment '%@'...", [self.groupComment gb_description]);
		self.groupRegistrator(self, self.groupComment);
	}
	if (reset) self.groupComment = nil;
}

- (void)notifyAboutCommentIfNecessaryAndReset:(BOOL)reset {
	if (!self.comment) return;
	if (self.commentRegistrator) {
		LogParDebug(@"Notifying about %@comment '%@'...", self.isCommentInline ? @"inline " : @"", [self.comment gb_description]);
		self.commentRegistrator(self, self.comment, self.isCommentInline);
	}
	if (reset) self.comment = nil;
}

@end

@implementation CommentParser (CommentTextHandling)

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

@implementation CommentParser (DeterminingCommentKind)

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

@end
