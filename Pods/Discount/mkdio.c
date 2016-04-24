/*
 * mkdio -- markdown front end input functions
 *
 * Copyright (C) 2007 David L Parsons.
 * The redistribution terms are provided in the COPYRIGHT file that must
 * be distributed with this source code.
 */
#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "cstring.h"
#include "markdown.h"
#include "amalloc.h"

typedef ANCHOR(Line) LineAnchor;

/* create a new blank Document
 */
Document*
__mkd_new_Document()
{
    Document *ret = calloc(sizeof(Document), 1);

    if ( ret ) {
	if ( ret->ctx = calloc(sizeof(MMIOT), 1) ) {
	    ret->magic = VALID_DOCUMENT;
	    return ret;
	}
	free(ret);
    }
    return 0;
}


/* add a line to the markdown input chain, expanding tabs and
 * noting the presence of special characters as we go.
 */
void
__mkd_enqueue(Document* a, Cstring *line)
{
    Line *p = calloc(sizeof *p, 1);
    unsigned char c;
    int xp = 0;
    int           size = S(*line);
    unsigned char *str = (unsigned char*)T(*line);

    CREATE(p->text);
    ATTACH(a->content, p);

    while ( size-- ) {
	if ( (c = *str++) == '\t' ) {
	    /* expand tabs into ->tabstop spaces.  We use ->tabstop
	     * because the ENTIRE FREAKING COMPUTER WORLD uses editors
	     * that don't do ^T/^D, but instead use tabs for indentation,
	     * and, of course, set their tabs down to 4 spaces 
	     */
	    do {
		EXPAND(p->text) = ' ';
	    } while ( ++xp % a->tabstop );
	}
	else if ( c >= ' ' ) {
	    if ( c == '|' )
		p->flags |= PIPECHAR;
	    EXPAND(p->text) = c;
	    ++xp;
	}
    }
    EXPAND(p->text) = 0;
    S(p->text)--;
    p->dle = mkd_firstnonblank(p);
}


/* trim leading blanks from a header line
 */
void
__mkd_header_dle(Line *p)
{
    CLIP(p->text, 0, 1);
    p->dle = mkd_firstnonblank(p);
}


/* build a Document from any old input.
 */
typedef int (*getc_func)(void*);

Document *
populate(getc_func getc, void* ctx, int flags)
{
    Cstring line;
    Document *a = __mkd_new_Document();
    int c;
    int pandoc = 0;

    if ( !a ) return 0;

    a->tabstop = (flags & MKD_TABSTOP) ? 4 : TABSTOP;

    CREATE(line);

    while ( (c = (*getc)(ctx)) != EOF ) {
	if ( c == '\n' ) {
	    if ( pandoc != EOF && pandoc < 3 ) {
		if ( S(line) && (T(line)[0] == '%') )
		    pandoc++;
		else
		    pandoc = EOF;
	    }
	    __mkd_enqueue(a, &line);
	    S(line) = 0;
	}
	else if ( isprint(c) || isspace(c) || (c & 0x80) )
	    EXPAND(line) = c;
    }

    if ( S(line) )
	__mkd_enqueue(a, &line);

    DELETE(line);

    if ( (pandoc == 3) && !(flags & (MKD_NOHEADER|MKD_STRICT)) ) {
	/* the first three lines started with %, so we have a header.
	 * clip the first three lines out of content and hang them
	 * off header.
	 */
	Line *headers = T(a->content);

	a->title = headers;             __mkd_header_dle(a->title);
	a->author= headers->next;       __mkd_header_dle(a->author);
	a->date  = headers->next->next; __mkd_header_dle(a->date);

	T(a->content) = headers->next->next->next;
    }

    return a;
}


/* convert a file into a linked list
 */
Document *
mkd_in(FILE *f, DWORD flags)
{
    return populate((getc_func)fgetc, f, flags & INPUT_MASK);
}


/* return a single character out of a buffer
 */
int
__mkd_io_strget(struct string_stream *in)
{
    if ( !in->size ) return EOF;

    --(in->size);

    return *(in->data)++;
}


/* convert a block of text into a linked list
 */
Document *
mkd_string(const char *buf, int len, DWORD flags)
{
    struct string_stream about;

    about.data = buf;
    about.size = len;

    return populate((getc_func)__mkd_io_strget, &about, flags & INPUT_MASK);
}


/* write the html to a file (xmlified if necessary)
 */
int
mkd_generatehtml(Document *p, FILE *output)
{
    char *doc;
    int szdoc;

    if ( (szdoc = mkd_document(p, &doc)) != EOF ) {
	if ( p->ctx->flags & MKD_CDATA )
	    mkd_generatexml(doc, szdoc, output);
	else
	    fwrite(doc, szdoc, 1, output);
	putc('\n', output);
	return 0;
    }
    return -1;
}


/* convert some markdown text to html
 */
int
markdown(Document *document, FILE *out, int flags)
{
    if ( mkd_compile(document, flags) ) {
	mkd_generatehtml(document, out);
	mkd_cleanup(document);
	return 0;
    }
    return -1;
}


/* write out a Cstring, mangled into a form suitable for `<a href=` or `<a id=`
 */
void
mkd_string_to_anchor(char *s, int len, mkd_sta_function_t outchar,
				       void *out, int labelformat)
{
    unsigned char c;

    int i, size;
    char *line;

    size = mkd_line(s, len, &line, IS_LABEL);
    
    if ( labelformat && (size>0) && !isalpha(line[0]) )
	(*outchar)('L',out);
    for ( i=0; i < size ; i++ ) {
	c = line[i];
	if ( labelformat ) {
	    if ( isalnum(c) || (c == '_') || (c == ':') || (c == '-') || (c == '.' ) )
		(*outchar)(c, out);
	    else
		(*outchar)('.', out);
	}
	else
	    (*outchar)(c,out);
    }
	
    if (line)
	free(line);
}


/*  ___mkd_reparse() a line
 */
static void
mkd_parse_line(char *bfr, int size, MMIOT *f, int flags)
{
    ___mkd_initmmiot(f, 0);
    f->flags = flags & USER_FLAGS;
    ___mkd_reparse(bfr, size, 0, f, 0);
    ___mkd_emblock(f);
}


/* ___mkd_reparse() a line, returning it in malloc()ed memory
 */
int
mkd_line(char *bfr, int size, char **res, DWORD flags)
{
    MMIOT f;
    int len;
    
    mkd_parse_line(bfr, size, &f, flags);

    if ( len = S(f.out) ) {
	/* kludge alert;  we know that T(f.out) is malloced memory,
	 * so we can just steal it away.   This is awful -- there
	 * should be an opaque method that transparently moves 
	 * the pointer out of the embedded Cstring.
	 */
	EXPAND(f.out) = 0;
	*res = T(f.out);
	T(f.out) = 0;
	S(f.out) = ALLOCATED(f.out) = 0;
    }
    else {
	 *res = 0;
	 len = EOF;
     }
    ___mkd_freemmiot(&f, 0);
    return len;
}


/* ___mkd_reparse() a line, writing it to a FILE
 */
int
mkd_generateline(char *bfr, int size, FILE *output, DWORD flags)
{
    MMIOT f;

    mkd_parse_line(bfr, size, &f, flags);
    if ( flags & MKD_CDATA )
	mkd_generatexml(T(f.out), S(f.out), output);
    else
	fwrite(T(f.out), S(f.out), 1, output);

    ___mkd_freemmiot(&f, 0);
    return 0;
}


/* set the url display callback
 */
void
mkd_e_url(Document *f, mkd_callback_t edit)
{
    if ( f )
	f->cb.e_url = edit;
}


/* set the url options callback
 */
void
mkd_e_flags(Document *f, mkd_callback_t edit)
{
    if ( f )
	f->cb.e_flags = edit;
}


/* set the url display/options deallocator
 */
void
mkd_e_free(Document *f, mkd_free_t dealloc)
{
    if ( f )
	f->cb.e_free = dealloc;
}


/* set the url display/options context data field
 */
void
mkd_e_data(Document *f, void *data)
{
    if ( f )
	f->cb.e_data = data;
}


/* set the href prefix for markdown extra style footnotes
 */
void
mkd_ref_prefix(Document *f, char *data)
{
    if ( f )
	f->ref_prefix = data;
}
