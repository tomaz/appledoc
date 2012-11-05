//
//  CommentNamedSectionInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 31.10.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "CommentSectionInfo.h"

/** Handles data for comment named section (parameters, exceptions).
 */
@interface CommentNamedSectionInfo : CommentSectionInfo

@property (nonatomic, copy) NSString *sectionName;

@end
