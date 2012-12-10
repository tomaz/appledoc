//
//  DetectCrossReferencesTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 24.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorCommentTask.h"

/** Implements concrete ProcessorCommentTask for detecting cross references in comments.
 
 The purpose of this task is detect cross references to known objects in given comment components.
 */
@interface DetectCrossReferencesTask : ProcessorCommentTask

@end
