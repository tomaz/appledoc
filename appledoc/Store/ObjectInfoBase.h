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
 
 @warning **Note:** Note that the class conforms to StoreRegistrar protocol. This is so that subclasses can be used as registrars. However ObjectInfoBase itself simply delegates all registrar methods to it's assigned registrar object. If a subclass has a need to implement different behavior, it should override all StoreRegistrar methods and not call super implementation!
 */
@interface ObjectInfoBase : NSObject <StoreRegistrar>

- (id)initWithRegistrar:(id<StoreRegistrar>)registrar;

@property (nonatomic, strong) PKToken *sourceToken;
@property (nonatomic, assign) id<StoreRegistrar> objectRegistrar;

@end
