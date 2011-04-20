/*
 *  PKTypes.h
 *  ParseKit
 *
 *  Created by Todd Ditchendorf on 3/15/09.
 *  Copyright 2009 Todd Ditchendorf. All rights reserved.
 *
 */

// a UTF-16 character. signed so that it may represent -1 as well
typedef SInt32      PKUniChar;

#define PKEOF       (PKUniChar)-1