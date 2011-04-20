//
//  PKDelimitedString.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 5/21/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      PKDelimitedString
    @brief      A <tt>PKDelimitedString</tt> matches a delimited string from a token assembly.
*/
@interface PKDelimitedString : PKTerminal {
    NSString *startMarker;
    NSString *endMarker;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKDelimitedString</tt> object.
    @result     an initialized autoreleased <tt>PKDelimitedString</tt> object
*/
+ (id)delimitedString;

+ (id)delimitedStringWithStartMarker:(NSString *)start;

+ (id)delimitedStringWithStartMarker:(NSString *)start endMarker:(NSString *)end;
@end
