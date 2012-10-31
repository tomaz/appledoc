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
@property (nonatomic, strong) NSMutableArray *commentDiscussion;
@property (nonatomic, strong) PKToken *sourceToken;
@property (nonatomic, strong) NSString *sourceString;

@end
