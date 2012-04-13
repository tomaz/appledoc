//
//  ClassInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "InterfaceInfoBase.h"

/** Holds information about a class.
 */
@interface ClassInfo : InterfaceInfoBase

@property (nonatomic, copy) NSString *nameOfClass;
@property (nonatomic, copy) NSString *nameOfSuperClass;

@end
