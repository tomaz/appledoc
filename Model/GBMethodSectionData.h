//
//  GBMethodSectionData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 22.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBMethodData;

/** Definition of a method section.
 
 Method section contains a list of related methods and is used for grouping different groups of methods in the final output. This is only a thin wrapper over an `NSArray` so it doesn't provide must of validation code found in other classes. It simply defines accessors and mutators for changing the values.
 */
@interface GBMethodSectionData : NSObject {
	@private
	NSMutableArray *_methods;
}

///---------------------------------------------------------------------------------------
/// @name Section data handling
///---------------------------------------------------------------------------------------

/** Registers the given method to the end of the section's methods list.
 
 As `GBMethodSectionData` is a thin wrapper over an `NSArray`, no validation is done, the given object is simply added to the end of the `methods` array. Client should make sure there is no duplication and implement other constraints. If the array is `nil`, a new instance is created before adding.
 
 @param method The method to register.
 @exception NSException Thrown if the given method is `nil`.
 @see unregisterMethod:
 @see methods
 @see sectionName
 */
- (void)registerMethod:(GBMethodData *)method;

/** Unregisters the given method from the section's methods list.
 
 If the method isn't part of the section, nothing happens.
 
 @param method The method to remove.
 @return Returns `YES` if the method was found in the list (and was consequently deleted), `NO` otherwise.
 @see registerMethod:
 */
- (BOOL)unregisterMethod:(GBMethodData *)method;

/** The name of the section.
 
 @see methods
 */
@property (copy) NSString *sectionName;

/** The array of section methods in the order of registration. 
 
 Each entry is an instance of `GBMethodData` and should be registered through `registerMethod:` method.
 
 @see registerMethod:
 */
@property (readonly) NSArray *methods;

@end
