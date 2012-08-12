//
//  ProcessCommentComponentsTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorTask.h"

/** Implements concrete ProcessorTask for splitting comment string into components.
 
 The purpose of this task is to split single text into individual components such as abstract, discussion, and various directives - parameters, exceptions, related objects etc. All components are stored as part of the given CommentInfo properties so they are available for subsequent processing tasks.
 */
@interface ProcessCommentComponentsTask : ProcessorTask

@end
