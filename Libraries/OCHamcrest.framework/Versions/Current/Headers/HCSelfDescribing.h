//
//  OCHamcrest - HCSelfDescribing.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <Foundation/Foundation.h>

@protocol HCDescription;


/**
    The ability of an object to describe itself.
*/
@protocol HCSelfDescribing <NSObject>

/**
    Generates a description of the object.
    
    The description may be part of a description of a larger object of which this is just a
    component, so it should be worded appropriately.
    
    @param description The description to be built or appended to.
*/
- (void) describeTo:(id<HCDescription>)description;

@end
