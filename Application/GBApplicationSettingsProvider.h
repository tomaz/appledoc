//
//  GBApplicationSettingsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 3.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"

/** Main application settings provider.
 
 This object implements `GBApplicationStringsProviding` interface and is used by `GBAppledocApplication` to prepare application-wide settings including factory defaults, global and session values. The main purpose of the class is to simplify `GBAppledocApplication` class by decoupling it from the actual settings providing implementation.
 */
@interface GBApplicationSettingsProvider : NSObject <GBApplicationSettingsProviding>

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased instance of the class.
 */
+ (id)provider;

@end
