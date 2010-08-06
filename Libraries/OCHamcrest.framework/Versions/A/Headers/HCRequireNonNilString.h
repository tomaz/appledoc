//
//  OCHamcrest - HCRequireNonNilString.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Mac
#import <Foundation/Foundation.h>


namespace hamcrest {

/**
    Throws an NSException if @a string is nil.
*/
inline
void requireNonNilString(NSString* string)
{
    if (string == nil)
    {
        @throw [NSException exceptionWithName: @"NotAString"
                                       reason: @"Must be non-nil string"
                                     userInfo: nil];
    }
}

}   // namespace hamcrest
