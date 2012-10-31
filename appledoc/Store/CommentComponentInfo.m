//
//  CommentComponentInfo.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentComponentInfo.h"

@implementation CommentComponentInfo

@end

#pragma mark -

@implementation CommentComponentInfo (Logging)

- (NSString *)description {
	return [self.sourceString gb_description];
}

- (NSString *)debugDescription {
	return self.sourceString;
}

@end