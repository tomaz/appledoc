//
//  Processor.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "AppledocTask.h"

@class ProcessorTask;

/** Data processing entry point.
 
 This is the part of the application that post processes parsed data. It takes care of searching for cross references and the rest of the stuff needed for generation phase.
 
 To use, instantiate and send `runWithSettings:store:` message to instantiated object.
*/
@interface Processor : AppledocTask

@property (nonatomic, strong) ProcessorTask *splitCommentToSectionsTask;
@property (nonatomic, strong) ProcessorTask *registerCommentComponentsTask;
@property (nonatomic, strong) ProcessorTask *detectCrossReferencesTask;

@end
