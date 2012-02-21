//
//  NSException+GBException.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Adds helper methods to `NSException` for more organized code.
 */
@interface NSException (GBException)

/** Raises the exception with the given format.
 
 This is a shortcut for `raise:format:` method and makes exception creation code much less verbose. As we don't
 use specialized exception names, this makes sense...
 
 @param format A human readable message string representing exception reason.
 @param ... A comma separated list of arguments to substitute into the format.
 @exception NSException Always thrown ;)
 */
+ (void)raise:(NSString *)format, ...;

/** Raises the exception with the given `NSError` object.
 
 This is useful for converting `NSError`s into `NSException`s. The method allows the client to pass in additional
 context information which further aids diagnosting the exact reason for the exception. If no context information
 is desired, pass `nil` and only error information is used for formatting. As exception message can become quite
 verbose, it is split into several lines to make the output more readable.

 @param error The error that describes the reason.
 @param format A human readable message string explaining the context of the error.
 @param ... A comma separated list of arguments to substitute into the format.
 @exception NSException Always thrown ;)
 */
+ (void)raiseWithError:(NSError *)error format:(NSString *)format, ...;

@end
