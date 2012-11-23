//
//  CommentComponentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Holds data about individual comment component.
 
 Comment component describes a single section of the comment. A section is composed of a single or multiple paragraphs, each paragraph delimited by an empty line. Each paragraph can be either "normal" text or it can be one of various Markdown elements such as list, code block, table etc. The reason for splitting comment text into components is due to specially formatted sections such as @warning or @bug blocks - each component describes single block - either normal paragraphs or one of special sections.
 
 Note that section that require special formatting are represented by subclasses.
 */
@interface CommentComponentInfo : NSObject

+ (id)componentWithSourceString:(NSString *)string;

@property (nonatomic, copy) NSString *componentMarkdown;
@property (nonatomic, copy) NSString *sourceString;

@end

#pragma mark -

/** Concrete comment component describing a @warning section.
 */
@interface CommentWarningSectionInfo : CommentComponentInfo
@end

/** Concrete comment component describing a @bug section.
 */
@interface CommentBugSectionInfo : CommentComponentInfo
@end
