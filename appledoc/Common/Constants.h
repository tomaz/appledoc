//
//  Constants.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Application and task results.
 */
typedef NS_ENUM(NSUInteger,GBResult) {
	GBResultOk = 0,
	GBResultSystemError,
	GBResultFailedMatch,
};

/** Helper macro for simplifying processing of multiple subsequent methods that all return GBResult.
 */
#define GB_PROCESS(code) { NSInteger intermediateResult = code; if (intermediateResult > result) result = intermediateResult; }



