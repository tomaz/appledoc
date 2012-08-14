//
//  Constants.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Application and task results.
 */
enum {
	GBResultOk = 0,
	GBResultSystemError,
	GBResultFailedMatch,
};
typedef NSInteger GBResult;

/** Helper macro for simplifying processing of multiple subsequent methods that all return GBResult.
 */
#define GB_PROCESS(code) { NSInteger intermediateResult = code; if (intermediateResult > result) result = intermediateResult; }



