//
//  MergeKnownObjectsTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 6.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorTask.h"

/** Merges known objects in the Store accoring to settings.
 
 This is where extensions and categories are merged to their classes as well as links to external members are established.
 */
@interface MergeKnownObjectsTask : ProcessorTask

@end
