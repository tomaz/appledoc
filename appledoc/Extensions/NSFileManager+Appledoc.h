//
//  NSFileManager+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@interface NSFileManager (Appledoc)

- (BOOL)gb_fileExistsAndIsFileAtPath:(NSString *)path;
- (BOOL)gb_fileExistsAndIsDirectoryAtPath:(NSString *)path;

@end

