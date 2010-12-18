//
//  GBObjectDataProviding.h
//  appledoc
//
//  Created by Tomaz Kragelj on 7.9.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBAdoptedProtocolsProvider;
@class GBMethodsProvider;
@class GBComment;

/** Defines the requirements for object data providers.
 
 Object data providers are responsible for providing various bits of data from top level store objects.
 */
@protocol GBObjectDataProviding

/** Object's adopted protocols, available via `GBAdoptedProtocolsProvider`. */
@property (readonly) GBAdoptedProtocolsProvider *adoptedProtocols;

/** Object's methods, available via `GBMethodsProvider`. */
@property (readonly) GBMethodsProvider *methods;

@end
