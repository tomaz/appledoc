//
//  CommentInfo.m
//  appledoc
//
//  Created by Tomaz Kragelj on 6/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"

@implementation CommentInfo

@end

#pragma mark - 

@implementation CommentInfo (Logging)

- (NSString *)description {
	return self.sourceString;
}

@end