//
//  NSError+Appledoc.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

typedef NS_ENUM(NSUInteger, GBErrorCodes) {
	GBErrorCodeTemplatePathNotFound,
	GBErrorCodeTemplatePathNotDirectory,
};

#pragma mark - 

@interface NSError (Appledoc)

+ (NSError *)gb_errorWithCode:(NSInteger)code description:(NSString *)description reason:(NSString *)reason;

@end
