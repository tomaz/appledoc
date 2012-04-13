//
//  CategoryInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "InterfaceInfoBase.h"

/** Holds information about class categories and extensions.
 */
@interface CategoryInfo : InterfaceInfoBase

@property (nonatomic, copy) NSString *nameOfClass;
@property (nonatomic, copy) NSString *nameOfCategory;

@property (nonatomic, readonly) BOOL isCategory;
@property (nonatomic, readonly) BOOL isExtension;

@end
