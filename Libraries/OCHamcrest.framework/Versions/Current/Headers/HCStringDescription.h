//
//  OCHamcrest - HCStringDescription.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseDescription.h>

@protocol HCSelfDescribing;


/**
    An HCDescription that is stored as a string.
*/
@interface HCStringDescription : HCBaseDescription
{
    NSMutableString* accumulator;
}

/**
    Returns the description of an HCSelfDescribing object as a string.

    @param selfDescribing The object to be described.
    @return The description of the object.
*/
+ (NSString*) stringFrom:(id<HCSelfDescribing>)selfDescribing;

/**
    Returns an empty description.
*/
+ (HCStringDescription*) stringDescription;

/**
    Returns an initialized HCStringDescription object that is empty.
*/
- (id) init;

@end
