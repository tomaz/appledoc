/* markdown: a C implementation of John Gruber's Markdown markup language.
 *
 * Copyright (C) 2007 David L Parsons.
 * The redistribution terms are provided in the COPYRIGHT file that must
 * be distributed with this source code.
 */
#include "config.h"

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#include "cstring.h"
#include "markdown.h"
#include "amalloc.h"
#include "tags.h"
    
static int need_to_initrng = 1;

void
mkd_initialize()
{

    if ( need_to_initrng ) {
	need_to_initrng = 0;
	INITRNG(time(0));
    }
}


void
mkd_shlib_destructor()
{
    mkd_deallocate_tags();
}

