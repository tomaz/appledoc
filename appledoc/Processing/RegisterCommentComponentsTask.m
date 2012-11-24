//
//  RegisterCommentComponentsTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "CommentComponentInfo.h"
#import "CommentNamedSectionInfo.h"
#import "RegisterCommentComponentsTask.h"

@interface RegisterCommentComponentsTask ()
@property (nonatomic, strong) NSMutableArray *sections;
@end

#pragma mark - 

@implementation RegisterCommentComponentsTask

#pragma mark - Processing

- (NSInteger)processComment:(CommentInfo *)comment {
	LogVerbose(@"Registering '%@' components...", [comment.sourceString gb_description]);
	self.sections = [comment.sourceSections mutableCopy];
	[self registerAbstractForComment:comment];
	[self registerDiscussionForComment:comment];
	[self registerMethodForComment:comment];
	return GBResultOk;
}

#pragma mark - Registering sections to comment

- (void)registerAbstractForComment:(CommentInfo *)comment {
	LogDebug(@"Registering abstract...");
	CommentComponentInfo *component = [self componentInfoFromString:self.sections[0]];
	[comment setCommentAbstract:component];
	[self.sections removeObjectAtIndex:0];
}

- (void)registerDiscussionForComment:(CommentInfo *)comment {
	// Register all discussion sections - up until first parameter related section.
	NSRegularExpression *expression = [NSRegularExpression gb_methodSectionDelimiterMatchingExpression];
	CommentSectionInfo *discussion = nil;
	while (self.sections.count > 0) {
		NSString *sectionString = self.sections[0];
		NSTextCheckingResult *match = [expression gb_firstMatchIn:sectionString];
		if ([match gb_isMatchedAtStart]) break;
		if (!discussion) discussion = [[CommentSectionInfo alloc] init];
		CommentComponentInfo *component = [self componentInfoFromString:sectionString];
		[discussion.sectionComponents addObject:component];
		[self.sections removeObjectAtIndex:0];
	}
	if (discussion) [comment setCommentDiscussion:discussion];
}

- (void)registerMethodForComment:(CommentInfo *)comment {
	NSMutableArray *parameters = nil;
	NSMutableArray *exceptions = nil;
	CommentSectionInfo *result = nil;
	CommentSectionInfo *lastSection = nil;
	while (self.sections.count > 0) {
		NSString *sectionString = self.sections[0];
		if ([self matchParameterSectionFromString:sectionString toArray:&parameters]) continue;
		if ([self matchExceptionSectionFromString:sectionString toArray:&exceptions]) continue;
		if ([self matchReturnSectionFromString:sectionString toInfo:&result]) continue;
		break;
	}
	if (parameters) [comment setCommentParameters:parameters];
	if (exceptions) [comment setCommentExceptions:exceptions];
	if (result) [comment setCommentReturn:result];
}

#pragma mark - Matching method directives

- (BOOL)matchParameterSectionFromString:(NSString *)string toArray:(NSMutableArray **)array {
	NSRegularExpression *expression = [NSRegularExpression gb_paramMatchingExpression];
	return [self matchNamedMethodSectionFromString:string expression:expression toArray:array];
}

- (BOOL)matchExceptionSectionFromString:(NSString *)string toArray:(NSMutableArray **)array {
	NSRegularExpression *expression = [NSRegularExpression gb_exceptionMatchingExpression];
	return [self matchNamedMethodSectionFromString:string expression:expression toArray:array];
}

- (BOOL)matchReturnSectionFromString:(NSString *)string toInfo:(CommentSectionInfo **)dest {
	NSRegularExpression *expression = [NSRegularExpression gb_returnMatchingExpression];
	return [self matchSimpleSectionFromString:string expression:expression toInfo:dest];
}

- (BOOL)matchNamedMethodSectionFromString:(NSString *)string expression:(NSRegularExpression *)expression toArray:(NSMutableArray **)array {
	NSTextCheckingResult *match = [expression gb_firstMatchIn:string];
	if (!match) return NO;
	NSString *description = [match gb_remainingStringIn:string];
	CommentComponentInfo *component = [self componentInfoFromString:description];
	CommentNamedSectionInfo *info = [[CommentNamedSectionInfo alloc] init];
	[info setSectionName:[match gb_stringAtIndex:2 in:string]];
	[info.sectionComponents addObject:component];
	if (!*array) *array = [@[] mutableCopy];
	[*array addObject:info];
	[self.sections removeObjectAtIndex:0];
	return YES;
}

- (BOOL)matchSimpleSectionFromString:(NSString *)string expression:(NSRegularExpression *)expression toInfo:(CommentSectionInfo **)dest {
	NSTextCheckingResult *match = [expression gb_firstMatchIn:string];
	if (!match) return NO;
	NSString *description = [match gb_remainingStringIn:string];
	CommentComponentInfo *component = [self componentInfoFromString:description];
	CommentSectionInfo *info = [[CommentSectionInfo alloc] init];
	[info.sectionComponents addObject:component];
	*dest = info;
	[self.sections removeObjectAtIndex:0];
	return YES;
}

#pragma mark - Comment components handling

- (CommentComponentInfo *)componentInfoFromString:(NSString *)string {
	LogDebug(@"Creating component for %@...", string);
	if ([string hasPrefix:@"@warning"]) return [CommentWarningComponentInfo componentWithSourceString:string];
	if ([string hasPrefix:@"@bug"]) return [CommentBugComponentInfo componentWithSourceString:string];
	if ([self isStringCodeBlock:string]) return [CommentCodeBlockComponentInfo componentWithSourceString:string];
	return [CommentComponentInfo componentWithSourceString:string];
}

@end
