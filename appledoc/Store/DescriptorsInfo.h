//
//  DescriptorsInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/26/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Provides data for descriptors.
 
 Descriptors are tokens placed after an object such as property or method which provide additional data for compiler. For example `__attribute__((deprecated))`, `DEPRECATED_ATTRIBUTE`, `NS_REQUIRES_NIL_TERMINATION` etc. They are composed of an array of all tokens that constitute the descriptors, for example `@[@"__attribute__", @"(", @"(", @"deprecated", @")", @")"]`.
 
 @warnings **Implementation details:** Note that DescriptorsInfo is very similar to AttributesInfo and while the functionality could be handled easily inside a single class, spreading it does make the rest of the code more readable: for example: instead of enumerating the descriptors via `attributeItems`, we do it over `descriptorItems` array. While this could be addressed with a more general purpose naming scheme, it didn't *feel* right at the time of creating the classes. Also note that in compiler terminology, "descriptors" are usually referred to as attributes, however as we already have AttributesInfo class (used for handling Objective C declared property attributes), I decided to name it differently and chose descriptors - these are describing an object after all...
 */
@interface DescriptorsInfo : NSObject

@property (nonatomic, strong) NSMutableArray *descriptorItems;

@end
