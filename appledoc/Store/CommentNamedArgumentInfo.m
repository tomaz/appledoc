//
//  CommentNamedArgumentInfo.m
//  appledoc
//
//  Created by Tomaz Kragelj on 31.10.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentNamedArgumentInfo.h"

@implementation CommentNamedArgumentInfo

#pragma mark - Properties

- (NSMutableArray *)argumentComponents {
	if (_argumentComponents) return _argumentComponents;
	LogIntDebug(@"Initializing comment named argument components array due to first access...");
	_argumentComponents = [[NSMutableArray alloc] init];
	return _argumentComponents;
}

@end
