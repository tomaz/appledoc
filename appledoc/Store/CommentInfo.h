//
//  CommentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 6/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class PKToken;
@class CommentComponentInfo;

/** Holds data about a source code comment.
 */
@interface CommentInfo : NSObject

- (BOOL)isCommentAbstractRegistered;

@property (nonatomic, strong) CommentComponentInfo *commentAbstract;
@property (nonatomic, strong) NSMutableArray *commentDiscussion; // CommentComponentInfo
@property (nonatomic, strong) NSMutableArray *commentParameters; // CommentNamedSectionInfo
@property (nonatomic, strong) NSMutableArray *commentExceptions; // CommentNamedSectionInfo
@property (nonatomic, strong) PKToken *sourceToken;
@property (nonatomic, copy) NSString *sourceString;

@end
