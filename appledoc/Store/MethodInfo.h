//
//  MethodInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

@class TypeInfo;

/** Holds data for a class or interface Objective C method.
 */
@interface MethodInfo : ObjectInfoBase

@property (nonatomic, strong) NSString *methodType;
@property (nonatomic, strong) TypeInfo *methodResult;
@property (nonatomic, strong) NSMutableArray *methodArguments;

@end
