//
//  AttributesInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Provides data for property attributes.
 
 Attributes are composed of an array of all tokens that constitute the attributes, for example `@[@"nonatomic", @"strong"]` or `@[@"readonly", @"getter", @"=", @"isLive"]`. Other than storing the array of all attributes, this class also provides helper methods for getting information from composed attributes such as `getter=isLive`.
 
 @warnings **Implementation details:** Note that AttributesInfo is very similar to TypeInfo and while the functionality could be handled easily inside a single class, spreading it does make the rest of the code more readable: for example: instead of enumerating the attributes via `typeItems`, we do it over `attributeItems` array. While this could be addressed with a more general purpose naming scheme, it didn't *feel* right at the time of creating the classes.
 */
@interface AttributesInfo : NSObject

- (NSString *)valueForAttribute:(NSString *)attribute;

@property (nonatomic, strong) NSMutableArray *attributeItems;

@end
