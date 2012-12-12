//
//  MemberInfoBase.h
//  appledoc
//
//  Created by Tomaz Kragelj on 12.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

@class InterfaceInfoBase;

/** Specifies common attributes of an InterfaceInfoBase member.
 */
@interface MemberInfoBase : ObjectInfoBase

- (NSString *)descriptionWithParent;

@property (nonatomic, assign) InterfaceInfoBase *memberParent;

@end
