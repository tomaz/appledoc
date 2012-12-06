//
//  SplitCommentToSectionsTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorCommentTask.h"

/** Implements concrete ProcessorTask for splitting comment string into sections.
 
 The purpose of this task is to split single text into individual sections roughly representing various components such as abstract, discussion, and various directives - parameters, exceptions, related objects etc. All sections are stored as part of the given CommentInfo object, so they are available for further processing.
 */
@interface SplitCommentToSectionsTask : ProcessorCommentTask

@end
