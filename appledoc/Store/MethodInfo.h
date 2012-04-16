//
//  MethodInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

/** Holds data for a class or interface Objective C method.
 */
@interface MethodInfo : ObjectInfoBase

@property (nonatomic, strong) NSString *methodType;

@end
