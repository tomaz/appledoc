//
//  TypeInfo.h
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Provides data for a type specifier.
 
 Type specifier is composed of an array of all tokens that consitute type, for example `@[@"NSString", @"*"]` or `@[@"const", @"struct", @"my_struct"]` etc.
 */
@interface TypeInfo : NSObject

@property (nonatomic, strong) NSMutableArray *typeItems;

@end
