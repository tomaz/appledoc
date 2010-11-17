// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustache.h"


/**
 The major component of GRMustache version
 
 @since v1.0.0
 */
#define GRMUSTACHE_MAJOR_VERSION 1

/**
 The minor component of GRMustache version
 
 @since v1.0.0
 */
#define GRMUSTACHE_MINOR_VERSION 1

/**
 The patch-level component of GRMustache version
 
 @since v1.0.0
 */
#define GRMUSTACHE_PATCH_VERSION 0


/**
 A C struct that hold GRMustache version information
 
 @since v1.0.0
 */
typedef struct {
	int major;	/**< The major component of the version. */
	int minor;	/**< The minor component of the version. */
	int patch;	/**< The patch-level component of the version. */
} GRMustacheVersion;

/**
 Adds version method to the GRMustache class.

 @since v1.0.0
 */
@interface GRMustache(Version)
/**
 @returns the version of GRMustache as a GRMustacheVersion.
 
 @since v1.0.0
 */
+ (GRMustacheVersion)version;
@end
