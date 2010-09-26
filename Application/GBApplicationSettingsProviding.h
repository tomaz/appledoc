//
//  GBApplicationSettingsProviding.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBCommentComponentsProvider.h"

/** Defines the requirements for application-level settings providers.
 
 Application-level settings providers provide application-wide settings and properties that affect application handling.
 */
@protocol GBApplicationSettingsProviding

/** The list of all full or partial paths to be ignored. 
 
 It's recommended to check if a path string ends with any of the given paths before processing it. This should catch directory and file names properly as directories are processed first.
 */
@property (retain) NSMutableArray *ignoredPaths;

/** Returns the `GBCommentComponentsProvider` object that identifies comment components. */
@property (retain) GBCommentComponentsProvider *commentComponents;

@end
