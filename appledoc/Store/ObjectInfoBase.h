//
//  ObjectInfoBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StoreRegistrations.h"

@class PKToken;

/** The base class for all Store objects.
 
 This class serves as a base abstract class that implements common behavior and data storage for all Store objects.
 */
@interface ObjectInfoBase : NSObject <StoreRegistrar>

- (id)initWithRegistrar:(id<StoreRegistrar>)registrar;

@property (nonatomic, strong) PKToken *sourceToken;
@property (nonatomic, assign) id<StoreRegistrar> objectRegistrar;

@end
