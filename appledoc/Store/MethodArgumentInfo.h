//
//  MethodArgumentInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

@class TypeInfo;

/** Holds data for a signle argument for a MethodInfo.
 
 An argument is composed of a selector, optional types and optional variable name.
 */
@interface MethodArgumentInfo : ObjectInfoBase

@property (nonatomic, strong) TypeInfo *argumentType;
@property (nonatomic, copy) NSString *argumentSelector;
@property (nonatomic, copy) NSString *argumentVariable;

@property (nonatomic, readonly) BOOL isUsingVariable;

@end
