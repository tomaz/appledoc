//
//  FetchDocumentationTask.h
//  appledoc
//
//  Created by Tomaz Kragelj on 10.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProcessorTask.h"

/** Fetches documentation from other instances of objects.
 
 The purpose of this class is to fill out documentation of objects from the rest of the objects in the store. For example, it copies documentation of overriden methods from super classes or adopted protocols. This allows users to simplify and DRY their code while still keeping full documentation.
 */
@interface FetchDocumentationTask : ProcessorTask

@end
