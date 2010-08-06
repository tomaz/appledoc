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
#import <ParseKit/PKSequence.h>

/*!
    @class      PKTrack
    @brief      A <tt>PKTrack</tt> is a sequence that throws a <tt>PKTrackException</tt> if the sequence begins but does not complete.
    @details    If <tt>-[PKTrack allMatchesFor:] begins but does not complete, it throws a <tt>PKTrackException</tt>.
*/
@interface PKTrack : PKSequence {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>PKTrack</tt> parser.
    @result     an initialized autoreleased <tt>PKTrack</tt> parser.
*/
+ (PKTrack *)track;

+ (PKTrack *)trackWithSubparsers:(PKParser *)p1, ...;
@end
