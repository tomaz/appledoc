//
//  NSArray+GBArray.h
//  appledoc
//
//  Created by Tomaz Kragelj on 13.1.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Provides extensions to `NSArray` for simpler handling. */
@interface NSArray (GBArray)

/** Returns the first object in the receiver. 
 
 If array is empty, `nil` is returned.
 
 @return Returns the first object in the receiver.
 */
- (id)firstObject;

/** Determines if the receiver is an empty array.
 
 @return Returns `YES` if the receiver is an empty array, `NO` otherwise.
 */
- (BOOL)isEmpty;

@end

/** Provides extensions to `NSMutableArray` for simpler handling. */
@interface NSMutableArray (GBMutableArray)

/** Helper method for adding the given object to the end of the receiver.
 
 Internally the method sends the receiver `addObject:`, but using this method makes usage of array as stack more obvious.
 
 @param object The object to push to the end of the receiver.
 */
- (void)push:(id)object;

/** Helper method to removing the last object from the receiver.
 
 Internally the method sends the receiver `removeLastObject` and returns the removed object. If receiver is an empty array, exception is raised.
 
 @return Returns the object removed from the receiver.
 @exception NSException Raised if the receiver is an empty array.
 */
- (id)pop;

/** Helper method for looking at the last object in the receiver.
 
 Internally, the method sends the receiver `lastObject` message and returns the result. If the receiver is an empty array, `nil` is returned.
 
 @return Returns the last object in the receiver.
 */
- (id)peek;

@end
