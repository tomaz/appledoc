//
//  CommentComponentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Holds data about individual comment component.
 
 Comment component describes part of the comment, such as abstract. Each component can contain single or multiple paragraphs. However it can only contain single "section" such as warning, bug etc.
 */
@interface CommentComponentInfo : NSObject

@property (nonatomic, copy) NSString *componentMarkdown;
@property (nonatomic, copy) NSString *sourceString;

@end
