//
//  GBProtocolData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBAdoptedProtocolsProvider;

/** Describes a protocol. */
@interface GBProtocolData : NSObject {
	@private
	NSString *_protocolName;
	GBAdoptedProtocolsProvider *_adoptedProtocols;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes the protocol with he given name.
 
 This is the designated initializer.
 
 @param name The name of the protocol.
 @return Returns initialized object.
 @exception NSException Thrown if the given name is `nil` or empty.
 */
- (id)initWithName:(NSString *)name;

///---------------------------------------------------------------------------------------
/// @name Protocol data
///---------------------------------------------------------------------------------------

/** The name of the protocol. */
@property (readonly) NSString *protocolName;

/** Protocol's adopted protocols, available via `GBAdoptedProtocolsProvider`. */
@property (readonly) GBAdoptedProtocolsProvider *adoptedProtocols;

@end
