//
//  GBMethodsProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBMethodData.h"

/** A helper class that unifies methods handling.
 
 Dividing implementation of methods provider to a separate class allows us to abstract the logic and reuse it within any object
 that needs to handle methods using composition. This breaks down the code into simpler and more managable chunks. It also simplifies 
 methods parsing and handling. To use the class, simply "plug" it to the class that needs to handle methods and provide access through 
 public interface.
 
 The downside is that querrying code becomes a bit more verbose as another method or property needs to be sent before getting
 access to actual methods data.
 */
@interface GBMethodsProvider : NSObject {
	@private
	NSMutableArray *_methods;
	NSMutableDictionary *_methodsBySelectors;
}

/** Registers the given method to the providers data.
 
 If provider doesn't yet have the given method instance registered, the object is added to `methods` list. If the same object is already
 registered, nothing happens.
 
 @warning *Note:* If another instance of the method with the same selector is registered, an exception is thrown.
 
 @param method The method to register.
 @exception NSException Thrown if a method with the same selector is already registered.
 */
- (void)registerMethod:(GBMethodData *)method;

/** Merges data from the given methods provider.
 
 This copies all unknown methods from the given source to receiver and invokes merging of data for receivers methods 
 also found in source. It leaves source data intact.
 
 @param source `GBMethodsProvider` to merge from.
 */
- (void)mergeDataFromMethodsProvider:(GBMethodsProvider *)source;

/** The array of all registered methods as `GBMethodData` instances in the order of registration. */
@property (readonly) NSArray *methods;

@end
