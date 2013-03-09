#ifndef _MKDIO_D
#define _MKDIO_D

#include <stdio.h>

typedef void MMIOT;

typedef unsigned int mkd_flag_t;

/* line builder for markdown()
 */
MMIOT *mkd_in(FILE*,mkd_flag_t);		/* assemble input from a file */
MMIOT *mkd_string(const char*,int,mkd_flag_t);	/* assemble input from a buffer */

/* line builder for github flavoured markdown
 */
MMIOT *gfm_in(FILE*,mkd_flag_t);		/* assemble input from a file */
MMIOT *gfm_string(const char*,int,mkd_flag_t);	/* assemble input from a buffer */

void mkd_basename(MMIOT*,char*);

void mkd_initialize();
void mkd_with_html5_tags();
void mkd_shlib_destructor();

/* compilation, debugging, cleanup
 */
int mkd_compile(MMIOT*, mkd_flag_t);
int mkd_cleanup(MMIOT*);

/* markup functions
 */
int mkd_dump(MMIOT*, FILE*, int, char*);
int markdown(MMIOT*, FILE*, mkd_flag_t);
int mkd_line(char *, int, char **, mkd_flag_t);
typedef int (*mkd_sta_function_t)(const int,const void*);
void mkd_string_to_anchor(char *, int, mkd_sta_function_t, void*, int);
int mkd_xhtmlpage(MMIOT*,int,FILE*);

/* header block access
 */
char* mkd_doc_title(MMIOT*);
char* mkd_doc_author(MMIOT*);
char* mkd_doc_date(MMIOT*);

/* compiled data access
 */
int mkd_document(MMIOT*, char**);
int mkd_toc(MMIOT*, char**);
int mkd_css(MMIOT*, char **);
int mkd_xml(char *, int, char **);

/* write-to-file functions
 */
int mkd_generatehtml(MMIOT*,FILE*);
int mkd_generatetoc(MMIOT*,FILE*);
int mkd_generatexml(char *, int,FILE*);
int mkd_generatecss(MMIOT*,FILE*);
#define mkd_style mkd_generatecss
int mkd_generateline(char *, int, FILE*, mkd_flag_t);
#define mkd_text mkd_generateline

/* url generator callbacks
 */
typedef char * (*mkd_callback_t)(const char*, const int, void*);
typedef void   (*mkd_free_t)(char*, void*);

void mkd_e_url(void *, mkd_callback_t);
void mkd_e_flags(void *, mkd_callback_t);
void mkd_e_free(void *, mkd_free_t );
void mkd_e_data(void *, void *);

/* version#.
 */
extern char markdown_version[];
void mkd_mmiot_flags(FILE *, MMIOT *, int);
void mkd_flags_are(FILE*, mkd_flag_t, int);

void mkd_ref_prefix(MMIOT*, char*);


/* special flags for markdown() and mkd_text()
 */
#define MKD_NOLINKS	0x00000001	/* don't do link processing, block <a> tags  */
#define MKD_NOIMAGE	0x00000002	/* don't do image processing, block <img> */
#define MKD_NOPANTS	0x00000004	/* don't run smartypants() */
#define MKD_NOHTML	0x00000008	/* don't allow raw html through AT ALL */
#define MKD_STRICT	0x00000010	/* disable SUPERSCRIPT, RELAXED_EMPHASIS */
#define MKD_TAGTEXT	0x00000020	/* process text inside an html tag; no
* <em>, no <bold>, no html or [] expansion */
#define MKD_NO_EXT	0x00000040	/* don't allow pseudo-protocols */
#define MKD_NOEXT	MKD_NO_EXT	/* ^^^ (aliased for user convenience) */
#define MKD_CDATA	0x00000080	/* generate code for xml ![CDATA[...]] */
#define MKD_NOSUPERSCRIPT 0x00000100	/* no A^B */
#define MKD_NORELAXED	0x00000200	/* emphasis happens /everywhere/ */
#define MKD_NOTABLES	0x00000400	/* disallow tables */
#define MKD_NOSTRIKETHROUGH 0x00000800	/* forbid ~~strikethrough~~ */
#define MKD_TOC		0x00001000	/* do table-of-contents processing */
#define MKD_1_COMPAT	0x00002000	/* compatibility with MarkdownTest_1.0 */
#define MKD_AUTOLINK	0x00004000	/* make http://foo.com link even without <>s */
#define MKD_SAFELINK	0x00008000	/* paranoid check for link protocol */
#define MKD_NOHEADER	0x00010000	/* don't process header blocks */
#define MKD_TABSTOP	0x00020000	/* expand tabs to 4 spaces */
#define MKD_NODIVQUOTE	0x00040000	/* forbid >%class% blocks */
#define MKD_NOALPHALIST	0x00080000	/* forbid alphabetic lists */
#define MKD_NODLIST	0x00100000	/* forbid definition lists */
#define MKD_EXTRA_FOOTNOTE 0x00200000	/* enable markdown extra-style footnotes */
#define MKD_NOSTYLE	0x00400000	/* don't extract <style> blocks */
#define MKD_EMBED	MKD_NOLINKS|MKD_NOIMAGE|MKD_TAGTEXT

/* special flags for mkd_in() and mkd_string()
 */


#endif/*_MKDIO_D*/
