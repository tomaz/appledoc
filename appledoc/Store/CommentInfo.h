//
//  CommentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 6/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class PKToken;
@class CommentComponentInfo;
@class CommentSectionInfo;

/** Holds data about a source code comment.
 
 Each comment is split into the following distinct components:
 
 - Abstract: the first paragraph of the comment.
 - Discussion: thr rest of the paragraphs of the comment.
 - Parameters: only used for methods; contains all @param descriptions.
 - Exceptions: only used for methods; contains all @exception descriptions.
 - Return: only used for methods: contains @return value description.
 */
@interface CommentInfo : NSObject

- (BOOL)isCommentAbstractRegistered;

@property (nonatomic, strong) CommentComponentInfo *commentAbstract;
@property (nonatomic, strong) CommentSectionInfo *commentDiscussion;
@property (nonatomic, strong) NSMutableArray *commentParameters; // CommentNamedSectionInfo
@property (nonatomic, strong) NSMutableArray *commentExceptions; // CommentNamedSectionInfo
@property (nonatomic, strong) CommentSectionInfo *commentReturn;

@property (nonatomic, strong) NSMutableArray *sourceSections; // NSString
@property (nonatomic, strong) PKToken *sourceToken;
@property (nonatomic, copy) NSString *sourceString;

@end
