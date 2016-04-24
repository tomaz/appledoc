// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
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






/*
 * Set up standard GRMustache versions
 */
#define GRMUSTACHE_VERSION_7_0  7000






/* 
 * If max GRMustacheVersion not specified, assume 7.0
 */
#ifndef GRMUSTACHE_VERSION_MAX_ALLOWED
#define GRMUSTACHE_VERSION_MAX_ALLOWED    GRMUSTACHE_VERSION_7_0
#endif

/*
 * if min GRMustacheVersion not specified, assume max
 */
#ifndef GRMUSTACHE_VERSION_MIN_REQUIRED
#define GRMUSTACHE_VERSION_MIN_REQUIRED    GRMUSTACHE_VERSION_MAX_ALLOWED
#endif

/*
 * Error on bad values
 */
#if GRMUSTACHE_VERSION_MAX_ALLOWED < GRMUSTACHE_VERSION_MIN_REQUIRED
#error GRMUSTACHE_VERSION_MAX_ALLOWED must be >= GRMUSTACHE_VERSION_MIN_REQUIRED
#endif
#if GRMUSTACHE_VERSION_MIN_REQUIRED < GRMUSTACHE_VERSION_7_0
#error GRMUSTACHE_VERSION_MIN_REQUIRED must be >= GRMUSTACHE_VERSION_7_0
#endif






/*
 * AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER
 * 
 * Used on declarations introduced in GRMustache 7.0
 */
#define AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER

/*
 * AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED
 * 
 * Used on declarations introduced in GRMustache 7.0, 
 * and deprecated in GRMustache 7.0
 */
#define AVAILABLE_GRMUSTACHE_VERSION_7_0_AND_LATER_BUT_DEPRECATED    DEPRECATED_ATTRIBUTE

/*
 * DEPRECATED_IN_GRMUSTACHE_VERSION_7_0_AND_LATER
 * 
 * Used on types deprecated in GRMustache 7.0
 */
#define DEPRECATED_IN_GRMUSTACHE_VERSION_7_0_AND_LATER    DEPRECATED_ATTRIBUTE






