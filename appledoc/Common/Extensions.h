//
//  Extensions.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Appledoc)
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;
@end

enum {
	GBErrorCodeTemplatePathNotFound,
	GBErrorCodeTemplatePathNotDirectory,
};

#pragma mark - 

@interface NSFileManager (Appledoc)
- (BOOL)fileExistsAndIsDirectoryAtPath:(NSString *)path;
@end