//
//  MethodInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "MemberInfoBase.h"

@class TypeInfo;
@class DescriptorsInfo;

/** Holds data for a class or interface Objective C method.
 */
@interface MethodInfo : MemberInfoBase

@property (nonatomic, copy) NSString *methodType;
@property (nonatomic, strong) TypeInfo *methodResult;
@property (nonatomic, strong) DescriptorsInfo *methodDescriptors;
@property (nonatomic, strong) NSMutableArray *methodArguments;
@property (nonatomic, readonly, copy) NSString *methodSelector;

@property (nonatomic, readonly) BOOL isClassMethod;
@property (nonatomic, readonly) BOOL isInstanceMethod;

@end
