//
//  GBTypedefEnumData.h
//  appledoc
//
//  Created by Rob van der Veer on 25/7/13.
//  Copyright (c) 2013 Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBObjectDataProviding.h"
#import "GBEnumConstantProvider.h"

/** Defines a single typedef enumeration, consisting of several constant definitions 
 *
 * The parser will populate the structures for use. Currently, only NS_ENUM type definitions are supported.
 */
@interface GBTypedefEnumData : GBModelBase
{
    @private
    NSString *_typedefName;
    GBEnumConstantProvider *_constants;
    NSString *_enumPrimitive;
    bool _isOptions;
}

+(id)typedefEnumWithName:(NSString *)name;

@property (readonly) NSString *nameOfEnum;
@property (readonly) GBEnumConstantProvider *constants;

/** The type of enum, e.g. for typdef NS_ENUM (NSInteger, name) {..} the value us `NSInteger` */
@property (copy) NSString *enumPrimitive;

/** True when the enum is defined as NS_OPTIONS */
@property (assign) bool isOptions;
@property (readonly) NSString *enumStyle;
@end
