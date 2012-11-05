//
//  CommentSectionInfo.m
//  appledoc
//
//  Created by Tomaz Kragelj on 5.11.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentSectionInfo.h"

@implementation CommentSectionInfo

#pragma mark - Properties

- (NSMutableArray *)sectionComponents {
	if (_sectionComponents) return _sectionComponents;
	LogIntDebug(@"Initializing comment named section components array due to first access...");
	_sectionComponents = [[NSMutableArray alloc] init];
	return _sectionComponents;
}

@end
