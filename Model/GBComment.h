//
//  GBComment.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Handles all comment related stuff.
 */
@interface GBComment : NSObject

/** Comment's raw string value as declared in source code. */
@property (copy) NSString *stringValue;

@end
