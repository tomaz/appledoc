//
//  EnumItemInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

/** Holds data for a single EnumInfo item.
 
 Enumeration item is very simple - it provides required name and optional value.
 */
@interface EnumItemInfo : ObjectInfoBase

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemValue;

@end
