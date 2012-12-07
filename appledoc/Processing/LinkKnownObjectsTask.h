//
//  LinkKnownObjectsTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 7.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorTask.h"

/** Prepares links to known objects.
 
 The purpose of this class is to link together all known objects. For example to link derived class to super class, adopted protocols, extensions and categories etc. This should be the first step of the processor as it prepares grounds for the rest of it.
 */
@interface LinkKnownObjectsTask : ProcessorTask

@end
