//
//  OCHamcrest - HCSubstringMatcher.h
//  Copyright 2009 www.hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid
//

    // Inherited
#import <OCHamcrest/HCBaseMatcher.h>


@interface HCSubstringMatcher : HCBaseMatcher
{
    NSString* substring;
}

- (id) initWithSubstring:(NSString*)aSubstring;

@end
