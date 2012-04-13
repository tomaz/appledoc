//
//  ObjectLinkData.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Provides data for a link to an object.
 
 This class serves two purposes: during parsing, it contains the name of the object within nameOfObject property. That name is used during post processing in order to get the link to the actual object. If found, the link is assigned to linkToObject property, otherwise it's kept to `nil`.
 */
@interface ObjectLinkData : NSObject

+ (id)objectLinkDataWithName:(NSString *)name;

@property (nonatomic, copy) NSString *nameOfObject;
@property (nonatomic, strong) id linkToObject;

@end

#pragma mark - 

/** Provides convenience methods for finding ObjectLinkData in an array by its name.
 */
@interface NSArray (ObjectLinkDataExtensions)

- (BOOL)gb_containsObjectLinkDataWithName:(NSString *)name;
- (NSUInteger)gb_indexOfObjectLinkDataWithName:(NSString *)name;

@end
