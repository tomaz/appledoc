/*
 * Copyright (c) 2007-2013 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <Foundation/Foundation.h>


/**
 * A option parsing exception. This should cause the program to
 * terminate with the given exit code.
 */
@interface DDCliParseException : NSException
{
    @private
    int _exitCode;
}

/**
 * Create a new exception with a given reason and exit code.
 *
 * @param reason Reason for the exception
 * @param exitCode Desired exit code
 * @return Autoreleased exception
 */
+ (DDCliParseException *)parseExceptionWithReason:(NSString *)reason
                                         exitCode:(int)exitCode;

/**
 * Create a new exception with a given reason and exit code.
 *
 * @param reason Reason for the exception
 * @param exitCode Desired exit code
 * @return New exception
 */
- (id)initWithReason:(NSString *)reason
            exitCode:(int)exitCode;

/**
 * Returns the desired exit code.
 *
 * @return The desired exit code
 */
- (int)exitCode;

@end
