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

/** Returns the `GBCommentComponentsProvider` object that identifies comment components. */
@property (retain) GBCommentComponentsProvider *commentComponents;

@end
