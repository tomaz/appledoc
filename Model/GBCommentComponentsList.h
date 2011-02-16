//
//  GBCommentComponentsList.h
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Handles a list of `GBCommentComponent`s.
 
 Although we could handle the lists as `NSArray`s directly, having additional layer in-between unifies the access to the list and simplifies the interface.
 */
@interface GBCommentComponentsList : NSObject {
	@private
    NSMutableArray *_components;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased instance of an empty list object.
 
 This is just convenience initializer method.
 */
+ (id)componentsList;

///---------------------------------------------------------------------------------------
/// @name List handling
///---------------------------------------------------------------------------------------

/** Registers the given `GBCommentComponent` to the `components` list.
 
 The component is added to the end of the list.
 
 @param component The component to register.
 @exception NSException Thrown if the given component is `nil`.
 */
- (void)registerComponent:(id)component;

/** The list of all components as `GBCommentComponent` instances in the list.
 */
@property (readonly) NSArray *components;

@end
