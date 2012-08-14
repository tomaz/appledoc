//
//  Store.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StoreConstants.h"
#import "StoreRegistrations.h"

#import "TypeInfo.h"
#import "ObjectLinkInfo.h"
#import "AttributesInfo.h"
#import "DescriptorsInfo.h"
#import "EnumItemInfo.h"
#import "MethodGroupInfo.h"
#import "MethodArgumentInfo.h"

#import "ClassInfo.h"
#import "CategoryInfo.h"
#import "ProtocolInfo.h"
#import "EnumInfo.h"
#import "StructInfo.h"

#import "PropertyInfo.h"
#import "MethodInfo.h"

#import "ConstantInfo.h"

#import "CommentInfo.h"
#import "CommentComponentInfo.h"

@class PKToken;

/** The main data store for the application.
 
 The store contains all objects parsed from input files. It's designed as the central object for passing data around various components.
 
 @warning **Implementation detail:** Store is implemented in the way to make registration of various objects as easy as possible. Therefore it let's you build up the objects as data is parsed in. For each object there's corresponding begin method which you need to call prior to registering various data. After all data is collected, you should send `endCurrentObject` to actually register the object with the store. If you detect any inconsistency, you should send `cancelCurrentObject` to cancel further registrations. You can nest begin/end/cancel calls, but they need to be balanced: each begin must be followed by an end or cancel! Internally, Store uses a stack on which objects are added when they are started and removed once they are done or cancelled.
 */
@interface Store : NSObject <StoreRegistrar>

@property (nonatomic, strong) NSMutableArray *storeClasses;
@property (nonatomic, strong) NSMutableArray *storeExtensions;
@property (nonatomic, strong) NSMutableArray *storeCategories;
@property (nonatomic, strong) NSMutableArray *storeProtocols;
@property (nonatomic, strong) NSMutableArray *storeEnumerations;
@property (nonatomic, strong) NSMutableArray *storeStructs;
@property (nonatomic, strong) NSMutableArray *storeConstants;

@end
