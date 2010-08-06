//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
+ (PKDelimitedString *)delimitedString;

+ (PKDelimitedString *)delimitedStringWithStartMarker:(NSString *)start;

+ (PKDelimitedString *)delimitedStringWithStartMarker:(NSString *)start endMarker:(NSString *)end;
@end
