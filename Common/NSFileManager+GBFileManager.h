//
//  NSFileManager+GBFileManager.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Extensions to `NSFileManager`.
 */
@interface NSFileManager (GBFileManager)

/** Determines if the given path is a directory.
 
 The method returns `YES` if the given path exists and is a directory, `NO` otherwise. This makes directory checking
 one-line of code, however does not give information on whether the path exists or not! Use `
 
 @param path The path to test.
 @return Returns `YES` if the given path is a directory, `NO` otherwise.
 */
- (BOOL)isPathDirectory:(NSString *)path;

@end
