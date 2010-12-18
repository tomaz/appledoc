//
//  NSObject+GBObject.m
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "NSObject+GBObject.h"

@implementation NSObject (GBObject)

- (NSFileManager *)fileManager {
	return [NSFileManager defaultManager];
}

- (NSString *)debugDescription {
	return [self description];
}

@end
