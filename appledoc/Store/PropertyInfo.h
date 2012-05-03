//
//  PropertyInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

@class AttributesInfo;
@class DescriptorsInfo;
@class TypeInfo;

/** Holds data for an Objective C property.
 */
@interface PropertyInfo : ObjectInfoBase

- (NSString *)propertyGetterSelector;
- (NSString *)propertySetterSelector;

@property (nonatomic, strong) TypeInfo *propertyType;
@property (nonatomic, strong) AttributesInfo *propertyAttributes;
@property (nonatomic, strong) DescriptorsInfo *propertyDescriptors;
@property (nonatomic, copy) NSString *propertyName;

@end
