//
//  ObjectLinkInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Provides data for a link to an object.
 
 This class serves two purposes: during parsing, it contains the name of the object within nameOfObject property. That name is used during post processing in order to get the link to the actual object. If found, the link is assigned to linkToObject property, otherwise it's kept to `nil`.
 */
@interface ObjectLinkInfo : NSObject

+ (id)ObjectLinkInfoWithName:(NSString *)name;

@property (nonatomic, copy) NSString *nameOfObject;
@property (nonatomic, strong) id linkToObject;

@end

#pragma mark - 

/** Provides convenience methods for finding ObjectLinkInfo in an array by its name.
 */
@interface NSArray (ObjectLinkInfoExtensions)

- (BOOL)gb_containsObjectLinkInfoWithName:(NSString *)name;
- (NSUInteger)gb_indexOfObjectLinkInfoWithName:(NSString *)name;

@end
