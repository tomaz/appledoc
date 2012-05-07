//
//  StructInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

/** Holds data for a C struct.
 
 A struct contains an array of all items which are in term other objects such as ConstantInfo etc.
 */
@interface StructInfo : ObjectInfoBase

@property (nonatomic, copy) NSString *nameOfStruct;
@property (nonatomic, strong) NSMutableArray *structItems;

@end
