//
//  CategoryInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "CategoryInfo.h"

@implementation CategoryInfo

@synthesize nameOfClass;
@synthesize nameOfCategory;

#pragma mark - Properties

- (BOOL)isCategory {
	return (self.nameOfCategory.length > 0);
}

- (BOOL)isExtension {
	return !self.isCategory;
}

@end
