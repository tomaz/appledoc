//
//  CommentComponentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Holds data about individual comment component.
 
 Comment component describes a single section of the comment. A section is composed of a single or multiple paragraphs, each paragraph delimited by an empty line. Each paragraph can be either "normal" text or it can be one of various Markdown elements such as list, code block, table etc. The reason for splitting comment text into components is due to specially formatted sections such as @warning or @bug blocks - each component describes single block - either normal paragraphs or one of special sections.
 */
@interface CommentComponentInfo : NSObject

+ (id)componentWithSourceString:(NSString *)string;

@property (nonatomic, copy) NSString *componentMarkdown;
@property (nonatomic, copy) NSString *sourceString;

@end
