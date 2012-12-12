//
//  MemberInfoBase.m
//  appledoc
//
//  Created by Tomaz Kragelj on 12.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "MemberInfoBase.h"

@implementation MemberInfoBase

- (NSString *)descriptionWithParent {
	return [NSString stringWithFormat:@"[%@ %@]", self.memberParent, self.uniqueObjectID];
}

@end
