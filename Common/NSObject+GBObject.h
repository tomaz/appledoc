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

@end
