//
//  ObjectiveCConstantState.h
//  appledoc
//
//  Created by Tomaž Kragelj on 5/7/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ObjectiveCParserState.h"

/** Concrete ObjectiveCParserState for parsing constants.
 
 Constants come in form of scope attributes, types, name and optional descriptors.
 */
@interface ObjectiveCConstantState : ObjectiveCParserState

@end
