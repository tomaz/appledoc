//
//  Parser.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "AppledocTask.h"

@class GBSettings;
@class Store;

/** Source code parsing entry point.
 
 This is the part of the application that parses known objects from input paths and registers them to Store for further processing.
 
 To use, instantiate and send `runWithSettings:store:` message to instantiated object.
 */
@interface Parser : AppledocTask

@end
