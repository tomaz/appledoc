//
//  NSException+GBException.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Adds helper methods to `NSException` for more organized code.
 */
@interface NSException (GBException)

/** Raises the exception with the given format.
 
 This is a shortcut for `raise:format:` method and makes exception creation code much less verbose. As we don't
 use specialized exception names, this makes sense...
 
 @param format A human readable message string representing exception reason.
 @param ... Variable information to be inserted into the formatted reason.
 @exception NSException Always thrown ;)
 */
+ (void)raise:(NSString *)format, ...;

@end
