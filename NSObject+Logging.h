//
//  NSObject+Logging.h
//  appledoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoggingProvider;

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines logging support for NSObject.

￼￼This adds a @c logger method whic is used to get the object's logger. This allows
simple logging implementation with various levels.
*/
@interface NSObject (Logging)

/** Returns the @c LoggingProvider implementor associated with this object.￼

This is used in @c log macros to get the object that will do the logging.

@return ￼￼￼￼Returns the logger object associated with the receiver.
*/
- (id<LoggingProvider>) logger;

@end
