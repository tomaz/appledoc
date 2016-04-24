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

typedef int (*stfu)(const void*,const void*);

typedef ANCHOR(Paragraph) ParagraphRoot;

static Paragraph *Pp(ParagraphRoot *, Line *, int);
static Paragraph *compile(Line *, int, MMIOT *);

/* case insensitive string sort for Footnote tags.
 */
int
__mkd_footsort(Footnote *a, Footnote *b)
{
    int i;
    char ac, bc;

    if ( S(a->tag) != S(b->tag) )
	return S(a->tag) - S(b->tag);

    for ( i=0; i < S(a->tag); i++) {
	ac = tolower(T(a->tag)[i]);
	bc = tolower(T(b->tag)[i]);

	if ( isspace(ac) && isspace(bc) )
	    continue;
	if ( ac != bc )
	    return ac - bc;
    }
    return 0;
}


/* find the first blank character after position <i>
 */
static int
nextblank(Line *t, int i)
{
    while ( (i < S(t->text)) && !isspace(T(t->text)[i]) )
	++i;
    return i;
}


/* find the next nonblank character after position <i>
 */
static int
nextnonblank(Line *t, int i)
{
    while ( (i < S(t->text)) && isspace(T(t->text)[i]) )
	++i;
    return i;
}


/* find the first nonblank character on the Line.
 */
int
mkd_firstnonblank(Line *p)
{
    return nextnonblank(p,0);
}


static inline int
blankline(Line *p)
{
    return ! (p && (S(p->text) > p->dle) );
}


static Line *
skipempty(Line *p)
{
    while ( p && (p->dle == S(p->text)) )
	p = p->next;
    return p;
}


void
___mkd_tidy(Cstring *t)
{
    while ( S(*t) && isspace(T(*t)[S(*t)-1]) )
	--S(*t);
}


static struct kw comment = { "!--", 3, 0 };

static struct kw *
isopentag(Line *p)
{
    int i=0, len;
    char *line;

    if ( !p ) return 0;

    line = T(p->text);
    len = S(p->text);

    if ( len < 3 || line[0] != '<' )
	return 0;

    if ( line[1] == '!' && line[2] == '-' && line[3] == '-' )
	/* comments need special case handling, because
	 * the !-- doesn't need to end in a whitespace
	 */
	return &comment;
    
    /* find how long the tag is so we can check to see if
     * it's a block-level tag
     */
    for ( i=1; i < len && T(p->text)[i] != '>' 
		       && T(p->text)[i] != '/'
		       && !isspace(T(p->text)[i]); ++i )
	;


    return mkd_search_tags(T(p->text)+1, i-1);
}


typedef struct _flo {
    Line *t;
    int i;
} FLO;

#define floindex(x) (x.i)


static int
flogetc(FLO *f)
{
    if ( f && f->t ) {
	if ( f->i < S(f->t->text) )
	    return T(f->t->text)[f->i++];
	f->t = f->t->next;
	f->i = 0;
	return flogetc(f);
    }
    return EOF;
}


static void
splitline(Line *t, int cutpoint)
{
    if ( t && (cutpoint < S(t->text)) ) {
	Line *tmp = calloc(1, sizeof *tmp);

	tmp->next = t->next;
	t->next = tmp;

	tmp->dle = t->dle;
	SUFFIX(tmp->text, T(t->text)+cutpoint, S(t->text)-cutpoint);
	S(t->text) = cutpoint;
    }
}

#define UNCHECK(l) ((l)->flags &= ~CHECKED)

/*
 * walk a line, seeing if it's any of half a dozen interesting regular
 * types.
 */
static void
checkline(Line *l)
{
    int eol, i;
    int dashes = 0, spaces = 0,
	equals = 0, underscores = 0,
	stars = 0, tildes = 0,
	backticks = 0;

    l->flags |= CHECKED;
    l->kind = chk_text;
    l->count = 0;
    
    if (l->dle >= 4) { l->kind=chk_code; return; }

    for ( eol = S(l->text); eol > l->dle && isspace(T(l->text)[eol-1]); --eol )
	;

    for (i=l->dle; i<eol; i++) {
	register int c = T(l->text)[i];

	if ( c != ' ' ) l->count++;

	switch (c) {
	case '-':  dashes = 1; break;
	case ' ':  spaces = 1; break;
	case '=':  equals = 1; break;
	case '_':  underscores = 1; break;
	case '*':  stars = 1; break;
#if WITH_FENCED_CODE
	case '~':  tildes = 1; break;
	case '`':  backticks = 1; break;
#endif
	default:   return;
	}
    }

    if ( dashes + equals + underscores + stars + tildes + backticks > 1 )
	return;

    if ( spaces ) {
	if ( (underscores || stars || dashes) )
	    l->kind = chk_hr;
	return;
    }

    if ( stars || underscores ) { l->kind = chk_hr; }
    else if ( dashes ) { l->kind = chk_dash; }
    else if ( equals ) { l->kind = chk_equal; }
#if WITH_FENCED_CODE
    else if ( tildes ) { l->kind = chk_tilde; }
    else if ( backticks ) { l->kind = chk_backtick; }
#endif
}



static Line *
commentblock(Paragraph *p, int *unclosed)
{
    Line *t, *ret;
    char *end;

    for ( t = p->text; t ; t = t->next) {
	if ( end = strstr(T(t->text), "-->") ) {
	    splitline(t, 3 + (end - T(t->text)) );
	    ret = t->next;
	    t->next = 0;
	    return ret;
	}
    }
    *unclosed = 1;
    return t;

}


static Line *
htmlblock(Paragraph *p, struct kw *tag, int *unclosed)
{
    Line *ret;
    FLO f = { p->text, 0 };
    int c;
    int i, closing, depth=0;

    *unclosed = 0;
    
    if ( tag == &comment )
	return commentblock(p, unclosed);
    
    if ( tag->selfclose ) {
	ret = f.t->next;
	f.t->next = 0;
	return ret;
    }

    while ( (c = flogetc(&f)) != EOF ) {
	if ( c == '<' ) {
	    /* tag? */
	    c = flogetc(&f);
	    if ( c == '!' ) { /* comment? */
		if ( flogetc(&f) == '-' && flogetc(&f) == '-' ) {
		    /* yes */
		    while ( (c = flogetc(&f)) != EOF ) {
			if ( c == '-' && flogetc(&f) == '-'
				      && flogetc(&f) == '>')
			      /* consumed whole comment */
			      break;
		    }
		}
	    }
	    else { 
		if ( closing = (c == '/') ) c = flogetc(&f);

		for ( i=0; i < tag->size; c=flogetc(&f) ) {
		    if ( tag->id[i++] != toupper(c) )
			break;
		}

		if ( (i == tag->size) && !isalnum(c) ) {
		    depth = depth + (closing ? -1 : 1);
		    if ( depth == 0 ) {
			while ( c != EOF && c != '>' ) {
			    /* consume trailing gunk in close tag */
			    c = flogetc(&f);
			}
			if ( c == EOF )
			    break;
			if ( !f.t )
			    return 0;
			splitline(f.t, floindex(f));
			ret = f.t->next;
			f.t->next = 0;
			return ret;
		    }
		}
	    }
	}
    }
    *unclosed = 1;
    return 0;
}


/* footnotes look like ^<whitespace>{0,3}[stuff]: <content>$
 */
static int
isfootnote(Line *t)
{
    int i;

    if ( ( (i = t->dle) > 3) || (T(t->text)[i] != '[') )
	return 0;

    for ( ++i; i < S(t->text) ; ++i ) {
	if ( T(t->text)[i] == '[' )
	    return 0;
	else if ( T(t->text)[i] == ']' )
	    return ( T(t->text)[i+1] == ':' ) ;
    }
    return 0;
}


static inline int
isquote(Line *t)
{
    return (t->dle < 4 && T(t->text)[t->dle] == '>');
}


static inline int
iscode(Line *t)
{
    return (t->dle >= 4);
}


static inline int
ishr(Line *t)
{
    if ( ! (t->flags & CHECKED) )
	checkline(t);

    if ( t->count > 2 )
	return t->kind == chk_hr || t->kind == chk_dash || t->kind == chk_equal;
    return 0;
}


static int
issetext(Line *t, int *htyp)
{
    Line *n;
    
    /* check for setext-style HEADER
     *                        ======
     */

    if ( (n = t->next) ) {
	if ( !(n->flags & CHECKED) )
	    checkline(n);

	if ( n->kind == chk_dash || n->kind == chk_equal ) {
	    *htyp = SETEXT;
	    return 1;
	}
    }
    return 0;
}


static int
ishdr(Line *t, int *htyp)
{
    /* ANY leading `#`'s make this into an ETX header
     */
    if ( (t->dle == 0) && (S(t->text) > 1) && (T(t->text)[0] == '#') ) {
	*htyp = ETX;
	return 1;
    }

    /* And if not, maybe it's a SETEXT header instead
     */
    return issetext(t, htyp);
}


static inline int
end_of_block(Line *t)
{
    int dummy;
    
    if ( !t )
	return 0;
	
    return ( (S(t->text) <= t->dle) || ishr(t) || ishdr(t, &dummy) );
}


static Line*
is_discount_dt(Line *t, int *clip)
{
#if USE_DISCOUNT_DL
    if ( t && t->next
	   && (S(t->text) > 2)
	   && (t->dle == 0)
	   && (T(t->text)[0] == '=')
	   && (T(t->text)[S(t->text)-1] == '=') ) {
	if ( t->next->dle >= 4 ) {
	    *clip = 4;
	    return t;
	}
	else
	    return is_discount_dt(t->next, clip);
    }
#endif
    return 0;
}


static int
is_extra_dd(Line *t)
{
    return (t->dle < 4) && (T(t->text)[t->dle] == ':')
			&& isspace(T(t->text)[t->dle+1]);
}


static Line*
is_extra_dt(Line *t, int *clip)
{
#if USE_EXTRA_DL
    
    if ( t && t->next && S(t->text) && T(t->text)[0] != '='
		      && T(t->text)[S(t->text)-1] != '=') {
	Line *x;
    
	if ( iscode(t) || end_of_block(t) )
	    return 0;

	if ( (x = skipempty(t->next)) && is_extra_dd(x) ) {
	    *clip = x->dle+2;
	    return t;
	}
	
	if ( x=is_extra_dt(t->next, clip) )
	    return x;
    }
#endif
    return 0;
}


static Line*
isdefinition(Line *t, int *clip, int *kind)
{
    Line *ret;

    *kind = 1;
    if ( ret = is_discount_dt(t,clip) )
	return ret;

    *kind=2;
    return is_extra_dt(t,clip);
}


static int
islist(Line *t, int *clip, DWORD flags, int *list_type)
{
    int i, j;
    char *q;
    
    if ( end_of_block(t) )
	return 0;

    if ( !(flags & (MKD_NODLIST|MKD_STRICT)) && isdefinition(t,clip,list_type) )
	return DL;

    if ( strchr("*-+", T(t->text)[t->dle]) && isspace(T(t->text)[t->dle+1]) ) {
	i = nextnonblank(t, t->dle+1);
	*clip = (i > 4) ? 4 : i;
	*list_type = UL;
	return AL;
    }

    if ( (j = nextblank(t,t->dle)) > t->dle ) {
	if ( T(t->text)[j-1] == '.' ) {

	    if ( !(flags & (MKD_NOALPHALIST|MKD_STRICT))
				    && (j == t->dle + 2)
			  && isalpha(T(t->text)[t->dle]) ) {
		j = nextnonblank(t,j);
		*clip = (j > 4) ? 4 : j;
		*list_type = AL;
		return AL;
	    }

	    strtoul(T(t->text)+t->dle, &q, 10);
	    if ( (q > T(t->text)+t->dle) && (q == T(t->text) + (j-1)) ) {
		j = nextnonblank(t,j);
		*clip = (j > 4) ? 4 : j;
		*list_type = OL;
		return AL;
	    }
	}
    }
    return 0;
}


static Line *
headerblock(Paragraph *pp, int htyp)
{
    Line *ret = 0;
    Line *p = pp->text;
    int i, j;

    switch (htyp) {
    case SETEXT:
	    /* p->text is header, p->next->text is -'s or ='s
	     */
	    pp->hnumber = (T(p->next->text)[0] == '=') ? 1 : 2;
	    
	    ret = p->next->next;
	    ___mkd_freeLine(p->next);
	    p->next = 0;
	    break;

    case ETX:
	    /* p->text is ###header###, so we need to trim off
	     * the leading and trailing `#`'s
	     */

	    for (i=0; (T(p->text)[i] == T(p->text)[0]) && (i < S(p->text)-1)
						       && (i < 6); i++)
		;

	    pp->hnumber = i;

	    while ( (i < S(p->text)) && isspace(T(p->text)[i]) )
		++i;

	    CLIP(p->text, 0, i);
	    UNCHECK(p);

	    for (j=S(p->text); (j > 1) && (T(p->text)[j-1] == '#'); --j)
		;

	    while ( j && isspace(T(p->text)[j-1]) )
		--j;

	    S(p->text) = j;

	    ret = p->next;
	    p->next = 0;
	    break;
    }
    return ret;
}


static Line *
codeblock(Paragraph *p)
{
    Line *t = p->text, *r;

    for ( ; t; t = r ) {
	CLIP(t->text,0,4);
	t->dle = mkd_firstnonblank(t);

	if ( !( (r = skipempty(t->next)) && iscode(r)) ) {
	    ___mkd_freeLineRange(t,r);
	    t->next = 0;
	    return r;
	}
    }
    return t;
}


#ifdef WITH_FENCED_CODE
static int
iscodefence(Line *r, int size, line_type kind)
{
    if ( !(r->flags & CHECKED) )
	checkline(r);

    if ( kind )
	return (r->kind == kind) && (r->count >= size);
    else
	return (r->kind == chk_tilde || r->kind == chk_backtick) && (r->count >= size);
}

static Paragraph *
fencedcodeblock(ParagraphRoot *d, Line **ptr)
{
    Line *first, *r;
    Paragraph *ret;

    first = (*ptr);
    
    /* don't allow zero-length code fences
     */
    if ( (first->next == 0) || iscodefence(first->next, first->count, 0) )
	return 0;

    /* find the closing fence, discard the fences,
     * return a Paragraph with the contents
     */
    for ( r = first; r && r->next; r = r->next )
	if ( iscodefence(r->next, first->count, first->kind) ) {
	    (*ptr) = r->next->next;
	    ret = Pp(d, first->next, CODE);
	    ___mkd_freeLine(first);
	    ___mkd_freeLine(r->next);
	    r->next = 0;
	    return ret;
	}
    return 0;
}
#endif


static int
centered(Line *first, Line *last)
{

    if ( first&&last ) {
	int len = S(last->text);

	if ( (len > 2) && (strncmp(T(first->text), "->", 2) == 0)
		       && (strncmp(T(last->text)+len-2, "<-", 2) == 0) ) {
	    CLIP(first->text, 0, 2);
	    S(last->text) -= 2;
	    return CENTER;
	}
    }
    return 0;
}


static int
endoftextblock(Line *t, int toplevelblock, DWORD flags)
{
    int z;

    if ( end_of_block(t) || isquote(t) )
	return 1;

    /* HORRIBLE STANDARDS KLUDGES:
     * 1. non-toplevel paragraphs absorb adjacent code blocks
     * 2. Toplevel paragraphs eat absorb adjacent list items,
     *    but sublevel blocks behave properly.
     * (What this means is that we only need to check for code
     *  blocks at toplevel, and only check for list items at
     *  nested levels.)
     */
    return toplevelblock ? 0 : islist(t,&z,flags,&z);
}


static Line *
textblock(Paragraph *p, int toplevel, DWORD flags)
{
    Line *t, *next;

    for ( t = p->text; t ; t = next ) {
	if ( ((next = t->next) == 0) || endoftextblock(next, toplevel, flags) ) {
	    p->align = centered(p->text, t);
	    t->next = 0;
	    return next;
	}
    }
    return t;
}


/* length of the id: or class: kind in a special div-not-quote block
 */
static int
szmarkerclass(char *p)
{
    if ( strncasecmp(p, "id:", 3) == 0 )
	return 3;
    if ( strncasecmp(p, "class:", 6) == 0 )
	return 6;
    return 0;
}


/*
 * check if the first line of a quoted block is the special div-not-quote
 * marker %[kind:]name%
 */
#define iscsschar(c) (isalpha(c) || (c == '-') || (c == '_') )

static int
isdivmarker(Line *p, int start, DWORD flags)
{
    char *s;
    int last, i;

    if ( flags & (MKD_NODIVQUOTE|MKD_STRICT) )
	return 0;

    last= S(p->text) - (1 + start);
    s   = T(p->text) + start;

    if ( (last <= 0) || (*s != '%') || (s[last] != '%') )
	return 0;

    i = szmarkerclass(s+1);

    if ( !iscsschar(s[i+1]) )
	return 0;
    while ( ++i < last )
	if ( !(isdigit(s[i]) || iscsschar(s[i])) )
	    return 0;

    return 1;
}


/*
 * accumulate a blockquote.
 *
 * one sick horrible thing about blockquotes is that even though
 * it just takes ^> to start a quote, following lines, if quoted,
 * assume that the prefix is ``> ''.   This means that code needs
 * to be indented *5* spaces from the leading '>', but *4* spaces
 * from the start of the line.   This does not appear to be 
 * documented in the reference implementation, but it's the
 * way the markdown sample web form at Daring Fireball works.
 */
static Line *
quoteblock(Paragraph *p, DWORD flags)
{
    Line *t, *q;
    int qp;

    for ( t = p->text; t ; t = q ) {
	if ( isquote(t) ) {
	    /* clip leading spaces */
	    for (qp = 0; T(t->text)[qp] != '>'; qp ++)
		/* assert: the first nonblank character on this line
		 * will be a >
		 */;
	    /* clip '>' */
	    qp++;
	    /* clip next space, if any */
	    if ( T(t->text)[qp] == ' ' )
		qp++;
	    CLIP(t->text, 0, qp);
	    UNCHECK(t);
	    t->dle = mkd_firstnonblank(t);
	}

	q = skipempty(t->next);

	if ( (q == 0) || ((q != t->next) && (!isquote(q) || isdivmarker(q,1,flags))) ) {
	    ___mkd_freeLineRange(t, q);
	    t = q;
	    break;
	}
    }
    if ( isdivmarker(p->text,0,flags) ) {
	char *prefix = "class";
	int i;
	
	q = p->text;
	p->text = p->text->next;

	if ( (i = szmarkerclass(1+T(q->text))) == 3 )
	    /* and this would be an "%id:" prefix */
	    prefix="id";
	    
	if ( p->ident = malloc(4+strlen(prefix)+S(q->text)) )
	    sprintf(p->ident, "%s=\"%.*s\"", prefix, S(q->text)-(i+2),
						     T(q->text)+(i+1) );

	___mkd_freeLine(q);
    }
    return t;
}


typedef int (*linefn)(Line *);


/*
 * pull in a list block.  A list block starts with a list marker and
 * runs until the next list marker, the next non-indented paragraph,
 * or EOF.   You do not have to indent nonblank lines after the list
 * marker, but multiple paragraphs need to start with a 4-space indent.
 */
static Line *
listitem(Paragraph *p, int indent, DWORD flags, linefn check)
{
    Line *t, *q;
    int clip = indent;
    int z;

    for ( t = p->text; t ; t = q) {
	CLIP(t->text, 0, clip);
	UNCHECK(t);
	t->dle = mkd_firstnonblank(t);

	if ( (q = skipempty(t->next)) == 0 ) {
	    ___mkd_freeLineRange(t,q);
	    return 0;
	}

	/* after a blank line, the next block needs to start with a line
	 * that's indented 4(? -- reference implementation allows a 1
	 * character indent, but that has unfortunate side effects here)
	 * spaces, but after that the line doesn't need any indentation
	 */
	if ( q != t->next ) {
	    if (q->dle < indent) {
		q = t->next;
		t->next = 0;
		return q;
	    }
	    /* indent at least 2, and at most as
	     * as far as the initial line was indented. */
	    indent = clip ? clip : 2;
	}

	if ( (q->dle < indent) && (ishr(q) || islist(q,&z,flags,&z)
					   || (check && (*check)(q)))
			       && !issetext(q,&z) ) {
	    q = t->next;
	    t->next = 0;
	    return q;
	}

	clip = (q->dle > indent) ? indent : q->dle;
    }
    return t;
}


static Line *
definition_block(Paragraph *top, int clip, MMIOT *f, int kind)
{
    ParagraphRoot d = { 0, 0 };
    Paragraph *p;
    Line *q = top->text, *text = 0, *labels; 
    int z, para;

    while (( labels = q )) {

	if ( (q = isdefinition(labels, &z, &kind)) == 0 )
	    break;

	if ( (text = skipempty(q->next)) == 0 )
	    break;

	if ( para = (text != q->next) )
	    ___mkd_freeLineRange(q, text);
	
	q->next = 0; 
	if ( kind == 1 /* discount dl */ )
	    for ( q = labels; q; q = q->next ) {
		CLIP(q->text, 0, 1);
		UNCHECK(q);
		S(q->text)--;
	    }

    dd_block:
	p = Pp(&d, text, LISTITEM);

	text = listitem(p, clip, f->flags, (kind==2) ? is_extra_dd : 0);
	p->down = compile(p->text, 0, f);
	p->text = labels; labels = 0;

	if ( para && p->down ) p->down->align = PARA;

	if ( (q = skipempty(text)) == 0 )
	    break;

	if ( para = (q != text) ) {
	    Line anchor;

	    anchor.next = text;
	    ___mkd_freeLineRange(&anchor,q);
	    text = q;
	    
	}

	if ( kind == 2 && is_extra_dd(q) )
	    goto dd_block;
    }
    top->text = 0;
    top->down = T(d);
    return text;
}


static Line *
enumerated_block(Paragraph *top, int clip, MMIOT *f, int list_class)
{
    ParagraphRoot d = { 0, 0 };
    Paragraph *p;
    Line *q = top->text, *text;
    int para = 0, z;

    while (( text = q )) {
	
	p = Pp(&d, text, LISTITEM);
	text = listitem(p, clip, f->flags, 0);

	p->down = compile(p->text, 0, f);
	p->text = 0;

	if ( para && p->down ) p->down->align = PARA;

	if ( (q = skipempty(text)) == 0
			     || islist(q, &clip, f->flags, &z) != list_class )
	    break;

	if ( para = (q != text) ) {
	    Line anchor;

	    anchor.next = text;
	    ___mkd_freeLineRange(&anchor, q);

	    if ( p->down ) p->down->align = PARA;
	}
    }
    top->text = 0;
    top->down = T(d);
    return text;
}


static int
tgood(char c)
{
    switch (c) {
    case '\'':
    case '"': return c;
    case '(': return ')';
    }
    return 0;
}


/*
 * add a new (image or link) footnote to the footnote table
 */
static Line*
addfootnote(Line *p, MMIOT* f)
{
    int j, i;
    int c;
    Line *np = p->next;

    Footnote *foot = &EXPAND(*f->footnotes);
    
    CREATE(foot->tag);
    CREATE(foot->link);
    CREATE(foot->title);
    foot->flags = foot->height = foot->width = 0;

    for (j=i=p->dle+1; T(p->text)[j] != ']'; j++)
	EXPAND(foot->tag) = T(p->text)[j];

    EXPAND(foot->tag) = 0;
    S(foot->tag)--;
    j = nextnonblank(p, j+2);

    if ( (f->flags & MKD_EXTRA_FOOTNOTE) && (T(foot->tag)[0] == '^') ) {
	while ( j < S(p->text) )
	    EXPAND(foot->title) = T(p->text)[j++];
	goto skip_to_end;
    }

    while ( (j < S(p->text)) && !isspace(T(p->text)[j]) )
	EXPAND(foot->link) = T(p->text)[j++];
    EXPAND(foot->link) = 0;
    S(foot->link)--;
    j = nextnonblank(p,j);

    if ( T(p->text)[j] == '=' ) {
	sscanf(T(p->text)+j, "=%dx%d", &foot->width, &foot->height);
	while ( (j < S(p->text)) && !isspace(T(p->text)[j]) )
	    ++j;
	j = nextnonblank(p,j);
    }


    if ( (j >= S(p->text)) && np && np->dle && tgood(T(np->text)[np->dle]) ) {
	___mkd_freeLine(p);
	p = np;
	np = p->next;
	j = p->dle;
    }

    if ( (c = tgood(T(p->text)[j])) ) {
	/* Try to take the rest of the line as a comment; read to
	 * EOL, then shrink the string back to before the final
	 * quote.
	 */
	++j;	/* skip leading quote */

	while ( j < S(p->text) )
	    EXPAND(foot->title) = T(p->text)[j++];

	while ( S(foot->title) && T(foot->title)[S(foot->title)-1] != c )
	    --S(foot->title);
	if ( S(foot->title) )	/* skip trailing quote */
	    --S(foot->title);
	EXPAND(foot->title) = 0;
	--S(foot->title);
    }

skip_to_end:
    ___mkd_freeLine(p);
    return np;
}


/*
 * allocate a paragraph header, link it to the
 * tail of the current document
 */
static Paragraph *
Pp(ParagraphRoot *d, Line *ptr, int typ)
{
    Paragraph *ret = calloc(sizeof *ret, 1);

    ret->text = ptr;
    ret->typ = typ;

    return ATTACH(*d, ret);
}



static Line*
consume(Line *ptr, int *eaten)
{
    Line *next;
    int blanks=0;

    for (; ptr && blankline(ptr); ptr = next, blanks++ ) {
	next = ptr->next;
	___mkd_freeLine(ptr);
    }
    if ( ptr ) *eaten = blanks;
    return ptr;
}


/*
 * top-level compilation; break the document into
 * style, html, and source blocks with footnote links
 * weeded out.
 */
static Paragraph *
compile_document(Line *ptr, MMIOT *f)
{
    ParagraphRoot d = { 0, 0 };
    ANCHOR(Line) source = { 0, 0 };
    Paragraph *p = 0;
    struct kw *tag;
    int eaten, unclosed;

    while ( ptr ) {
	if ( !(f->flags & MKD_NOHTML) && (tag = isopentag(ptr)) ) {
	    int blocktype;
	    /* If we encounter a html/style block, compile and save all
	     * of the cached source BEFORE processing the html/style.
	     */
	    if ( T(source) ) {
		E(source)->next = 0;
		p = Pp(&d, 0, SOURCE);
		p->down = compile(T(source), 1, f);
		T(source) = E(source) = 0;
	    }
	    
	    if ( f->flags & MKD_NOSTYLE )
		blocktype = HTML;
	    else
		blocktype = strcmp(tag->id, "STYLE") == 0 ? STYLE : HTML;
	    p = Pp(&d, ptr, blocktype);
	    ptr = htmlblock(p, tag, &unclosed);
	    if ( unclosed ) {
		p->typ = SOURCE;
		p->down = compile(p->text, 1, f);
		p->text = 0;
	    }
	}
	else if ( isfootnote(ptr) ) {
	    /* footnotes, like cats, sleep anywhere; pull them
	     * out of the input stream and file them away for
	     * later processing
	     */
	    ptr = consume(addfootnote(ptr, f), &eaten);
	}
	else {
	    /* source; cache it up to wait for eof or the
	     * next html/style block
	     */
	    ATTACH(source,ptr);
	    ptr = ptr->next;
	}
    }
    if ( T(source) ) {
	/* if there's any cached source at EOF, compile
	 * it now.
	 */
	E(source)->next = 0;
	p = Pp(&d, 0, SOURCE);
	p->down = compile(T(source), 1, f);
    }
    return T(d);
}


static int
first_nonblank_before(Line *j, int dle)
{
    return (j->dle < dle) ? j->dle : dle;
}


static int
actually_a_table(MMIOT *f, Line *pp)
{
    Line *r;
    int j;
    int c;

    /* tables need to be turned on */
    if ( f->flags & (MKD_STRICT|MKD_NOTABLES) )
	return 0;

    /* tables need three lines */
    if ( !(pp && pp->next && pp->next->next) ) {
	return 0;
    }

    /* all lines must contain |'s */
    for (r = pp; r; r = r->next )
	if ( !(r->flags & PIPECHAR) ) {
	    return 0;
	}

    /* if the header has a leading |, all lines must have leading |'s */
    if ( T(pp->text)[pp->dle] == '|' ) {
	for ( r = pp; r; r = r->next )
	    if ( T(r->text)[first_nonblank_before(r,pp->dle)] != '|' ) {
		return 0;
	    }
    }

    /* second line must be only whitespace, -, |, or : */
    r = pp->next;

    for ( j=r->dle; j < S(r->text); ++j ) {
	c = T(r->text)[j];

	if ( !(isspace(c)||(c=='-')||(c==':')||(c=='|')) ) {
	    return 0;
	}
    }

    return 1;
}


/*
 * break a collection of markdown input into
 * blocks of lists, code, html, and text to
 * be marked up.
 */
static Paragraph *
compile(Line *ptr, int toplevel, MMIOT *f)
{
    ParagraphRoot d = { 0, 0 };
    Paragraph *p = 0;
    Line *r;
    int para = toplevel;
    int blocks = 0;
    int hdr_type, list_type, list_class, indent;

    ptr = consume(ptr, &para);

    while ( ptr ) {
	if ( iscode(ptr) ) {
	    p = Pp(&d, ptr, CODE);
	    
	    if ( f->flags & MKD_1_COMPAT) {
		/* HORRIBLE STANDARDS KLUDGE: the first line of every block
		 * has trailing whitespace trimmed off.
		 */
		___mkd_tidy(&p->text->text);
	    }
	    
	    ptr = codeblock(p);
	}
#if WITH_FENCED_CODE
	else if ( iscodefence(ptr,3,0) && (p=fencedcodeblock(&d, &ptr)) )
	    /* yay, it's already done */ ;
#endif
	else if ( ishr(ptr) ) {
	    p = Pp(&d, 0, HR);
	    r = ptr;
	    ptr = ptr->next;
	    ___mkd_freeLine(r);
	}
	else if ( list_class = islist(ptr, &indent, f->flags, &list_type) ) {
	    if ( list_class == DL ) {
		p = Pp(&d, ptr, DL);
		ptr = definition_block(p, indent, f, list_type);
	    }
	    else {
		p = Pp(&d, ptr, list_type);
		ptr = enumerated_block(p, indent, f, list_class);
	    }
	}
	else if ( isquote(ptr) ) {
	    p = Pp(&d, ptr, QUOTE);
	    ptr = quoteblock(p, f->flags);
	    p->down = compile(p->text, 1, f);
	    p->text = 0;
	}
	else if ( ishdr(ptr, &hdr_type) ) {
	    p = Pp(&d, ptr, HDR);
	    ptr = headerblock(p, hdr_type);
	}
	else {
	    p = Pp(&d, ptr, MARKUP);
	    ptr = textblock(p, toplevel, f->flags);
	    /* tables are a special kind of paragraph */
	    if ( actually_a_table(f, p->text) )
		p->typ = TABLE;
	}

	if ( (para||toplevel) && !p->align )
	    p->align = PARA;

	blocks++;
	para = toplevel || (blocks > 1);
	ptr = consume(ptr, &para);

	if ( para && !p->align )
	    p->align = PARA;

    }
    return T(d);
}


/*
 * the guts of the markdown() function, ripped out so I can do
 * debugging.
 */

/*
 * prepare and compile `text`, returning a Paragraph tree.
 */
int
mkd_compile(Document *doc, DWORD flags)
{
    if ( !doc )
	return 0;

    if ( doc->compiled )
	return 1;

    doc->compiled = 1;
    memset(doc->ctx, 0, sizeof(MMIOT) );
    doc->ctx->ref_prefix= doc->ref_prefix;
    doc->ctx->cb        = &(doc->cb);
    doc->ctx->flags     = flags & USER_FLAGS;
    CREATE(doc->ctx->in);
    doc->ctx->footnotes = malloc(sizeof doc->ctx->footnotes[0]);
    CREATE(*doc->ctx->footnotes);

    mkd_initialize();

    doc->code = compile_document(T(doc->content), doc->ctx);
    qsort(T(*doc->ctx->footnotes), S(*doc->ctx->footnotes),
		        sizeof T(*doc->ctx->footnotes)[0],
			           (stfu)__mkd_footsort);
    memset(&doc->content, 0, sizeof doc->content);
    return 1;
}

