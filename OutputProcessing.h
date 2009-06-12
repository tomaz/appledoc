//
//  OutputProcessing.h
//  appledoc
//
//  Created by Tomaz Kragelj on 12.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** The @c OutputProcessing protocol defines methods that an output processing or
generating class must implement.
 
The methods consist of two groups. The main group is associated with the actual output
generation, while the helper group with additional tasks such as creating and removing
directories.
*/
@protocol OutputProcessing

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

/** Notifies output generator to start processing the data and generate output.
 
This message is sent only to conformers which return @c YES from
@c isOutputGenerationEnabled(). The conformers which receive the message should process
it without having to check again. It is the responsibility of the clients to ensure that
this message is sent only if output generation is enabled.

@exception NSException Thrown if output generation fails.
@see isOutputGenerationEnabled
*/
- (void) generateOutput;

/** Determines whether the specific output handled by conformer should be generated or not.￼

This answers the question "did user select the given output generation or not?".￼

@see generateOutput
*/
@property(readonly) BOOL isOutputGenerationEnabled;

@end
