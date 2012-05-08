//
//  EnumInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

/** Holds data for an enumeration.
 */
@interface EnumInfo : ObjectInfoBase

@property (nonatomic, copy) NSString *nameOfEnum;
@property (nonatomic, strong) NSMutableArray *enumItems;

@end
