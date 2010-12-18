//
//  NSObject+GBObject.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implementes common application-wide functionality.
 */
@interface NSObject (GBObject)

/** Returns the `NSFileManager` instance to use for dealing with OS.
 */
@property (readonly) NSFileManager *fileManager;

/** Description that can be used for debugging output.
 
 By default the value of `[NSObject description]` is returned, but some classes may override and provide more detailed information.
 */
@property (readonly) NSString *debugDescription;

@end
