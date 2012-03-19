//
//  GBSettings+Helpers.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings.h"

@interface GBSettings (Helpers)

- (void)applyFactoryDefaults;
- (BOOL)applyGlobalSettingsFromCmdLineSettings:(GBSettings *)settings;
- (BOOL)applyProjectSettingsFromCmdLineSettings:(GBSettings *)settings;
- (void)consolidateSettings;
- (BOOL)validateSettings;

@end
