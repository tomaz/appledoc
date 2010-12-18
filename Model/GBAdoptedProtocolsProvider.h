//
//  GBAdoptedProtocolsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBProtocolData;

/** A helper class that unifies adopted protocols handling.
 
 Dividing implementation of adopted protocols to a separate class allows us to abstract the logic and reuse it within any object that needs to handle adopted protocols using composition. It also simplifies protocols parsing and handling. To use it, simply "plug" it to the class that needs to handle adopted protocols and provide access through a public interface.
 
 The downside is that querrying code becomes a bit more verbose as another method or property needs to be sent before getting access to actual adopted protocols data.
 */
@interface GBAdoptedProtocolsProvider : NSObject {
	@private
	NSMutableSet *_protocols;
	NSMutableDictionary *_protocolsByName;
	id _parent;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Initializes ivars provider with the given parent object.
 
 The given parent object is set to each `GBIvarData` registered through `registerIvar:`. This is the designated initializer.
 
 @param parent The parent object to be used for all registered ivars.
 @return Returns initialized object.
 @exception NSException Thrown if the given parent is `nil`.
 */
- (id)initWithParentObject:(id)parent;

///---------------------------------------------------------------------------------------
/// @name Adopted protocols handling
///---------------------------------------------------------------------------------------

/** Registers the given protocol to the providers data.
 
 If provider doesn't yet have the given protocol instance registered, the object is added to `protocols` list. If the same object is already registered, nothing happens.
 
 @warning *Note:* If another instance of the protocol with the same name is registered, an exception is thrown.
 
 @param protocol The protocol to register.
 @exception NSException Thrown if the given protocol is already registered.
 */
- (void)registerProtocol:(GBProtocolData *)protocol;

/** Merges data from the given protocol provider.
 
 This copies all unknown protocols from the given source to receiver and invokes merging of data for receivers protocols also found in source. It leaves source data intact.
 
 @param source `GBAdoptedProtocolsProvider` to merge from.
 */
- (void)mergeDataFromProtocolsProvider:(GBAdoptedProtocolsProvider *)source;

/** Replaces the given original adopted protocol with the new one.
 
 This is provided so that processor can replace known protocols "placeholders" with real ones..
 
 @param original Original protocol to replace.
 @param protocol The protocol to replace with.
 @exception NSException Thrown if original protocol is not in the current protocols list or new protocol is `nil`.
 */
- (void)replaceProtocol:(GBProtocolData *)original withProtocol:(GBProtocolData *)protocol;

/** Returns the array of all protocols sorted by their name. */
- (NSArray *)protocolsSortedByName;

/** The list of all protocols as instances of `GBProtocolData`. */
@property (readonly) NSSet *protocols;

@end
