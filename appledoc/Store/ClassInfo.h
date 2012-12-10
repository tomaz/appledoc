//
//  ClassInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

@class ObjectLinkInfo;

#import "InterfaceInfoBase.h"

/** Holds information about a class.
 */
@interface ClassInfo : InterfaceInfoBase

@property (nonatomic, copy) NSString *nameOfClass;
@property (nonatomic, strong) ObjectLinkInfo *classSuperClass;

@end
