//
//  PKTrack.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

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
+ (id)track;

+ (id)trackWithSubparsers:(PKParser *)p1, ...;
@end
