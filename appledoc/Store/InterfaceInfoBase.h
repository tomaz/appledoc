//
//  InterfaceInfoBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectInfoBase.h"

/** Handles common stuff for all interface level objects - classes, categories and protocols.
 */
@interface InterfaceInfoBase : ObjectInfoBase

@property (nonatomic, strong) NSMutableArray *interfaceAdoptedProtocols; // ObjectLinkInfo
@property (nonatomic, strong) NSMutableArray *interfaceMethodGroups; // MethodGroupInfo
@property (nonatomic, strong) NSMutableArray *interfaceProperties; // PropertyInfo
@property (nonatomic, strong) NSMutableArray *interfaceInstanceMethods; // MethodInfo
@property (nonatomic, strong) NSMutableArray *interfaceClassMethods; // MethodInfo

@end
