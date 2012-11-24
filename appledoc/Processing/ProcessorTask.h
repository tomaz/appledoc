//
//  ProcessorTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "MarkdownParser.h"

@class GBSettings;
@class ObjectInfoBase;
@class CommentInfo;
@class Store;

/** Helper base class for handling processor task.
 
 This class simplifies and unifies behavior for all different processing tasks. For example a concrete processing task may handle cross references detection etc. Each concrete processor task should be designed to have its instance objects reusable. That is - each instance is only constructed once and the same instance gets invoked for processing during main invocation.
 
 @warning **Note:** Note that processing is handled by objects - each object also has comment assigned, so there's no need to pass comments separately. However for each object, it's context is also given. The context specifies the "parent" object of our object. Or better: each context is fully rendered on a single HTML page (rendering happens later on, during generation phase). So the context specifies the object that the page describes. For example: if the object that's being processed is a method, then the context is it's parent "top level" object (class, category or protocol). However if the object is already "top level" object, the context is the same object.
 */
@interface ProcessorTask : NSObject <MarkdownParserDelegate>

- (id)initWithStore:(Store *)store settings:(GBSettings *)settings;

- (NSInteger)processCommentForObject:(ObjectInfoBase *)object context:(ObjectInfoBase *)context;

@end

#pragma mark -

/** Private API for ProcessorTask subclasses.
 
 This is sent internally by ProcessorTask and should not be used otherwise.
 */
@interface ProcessorTask (Subclass)
- (NSInteger)processComment:(CommentInfo *)comment;
@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) GBSettings *settings;
@property (nonatomic, strong) ObjectInfoBase *processingObject;
@property (nonatomic, strong) ObjectInfoBase *processingContext;
@property (nonatomic, strong) MarkdownParser *markdownParser;
@end
