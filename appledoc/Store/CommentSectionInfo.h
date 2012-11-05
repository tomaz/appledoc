//
//  CommentSectionInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 5.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Handles data for comment named arguments (parameters, exceptions).
 */
@interface CommentSectionInfo : NSObject

@property (nonatomic, copy) NSMutableArray *sectionComponents; // CommentComponentInfo

@end
