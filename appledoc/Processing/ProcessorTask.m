//
//  ProcessorTask.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "ObjectInfoBase.h"
#import "MarkdownParser.h"
#import "ProcessorTask.h"

@interface ProcessorTask ()
@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) GBSettings *settings;
@property (nonatomic, strong) MarkdownParser *markdownParser;
@property (nonatomic, strong) ObjectInfoBase *processingObject;
@property (nonatomic, strong) ObjectInfoBase *processingContext;
@end

#pragma mark -

@implementation ProcessorTask

#pragma mark - Initialization & disposal

- (id)initWithStore:(Store *)store settings:(GBSettings *)settings {
	self = [super init];
	if (self) {
		self.store = store;
		self.settings = settings;
	}
	return self;
}

#pragma mark - Processing

- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)context {
	self.processingObject = object;
	self.processingContext = context;
	return [self processComment:object.comment];
}

#pragma mark - Lazy loading properties

- (MarkdownParser *)markdownParser {
	if (_markdownParser) return _markdownParser;
	LogDebug(@"Initializing markdown parser due to first access...");
	_markdownParser = [[MarkdownParser alloc] init];
	_markdownParser.delegate = self;
	return _markdownParser;
}

@end
