//
//  MarkdownParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "MarkdownParser.h"

static struct sd_callbacks gb_markdown_callbacks;

void gb_markdown_blockcode(struct buf *ob, const struct buf *text, const struct buf *lang, MarkdownParser *opaque);
void gb_markdown_blockquote(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
void gb_markdown_blockhtml(struct buf *ob,const  struct buf *text, MarkdownParser *opaque);
void gb_markdown_header(struct buf *ob, const struct buf *text, int level, MarkdownParser *opaque);
void gb_markdown_hrule(struct buf *ob, MarkdownParser *opaque);
void gb_markdown_list(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque);
void gb_markdown_listitem(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque);
void gb_markdown_paragraph(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
void gb_markdown_table(struct buf *ob, const struct buf *header, const struct buf *body, MarkdownParser *opaque);
void gb_markdown_table_row(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
void gb_markdown_table_cell(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque);

int gb_markdown_autolink(struct buf *ob, const struct buf *link, enum mkd_autolink type, MarkdownParser *opaque);
int gb_markdown_codespan(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
int gb_markdown_double_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
int gb_markdown_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
int gb_markdown_image(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, MarkdownParser *opaque);
int gb_markdown_linebreak(struct buf *ob, MarkdownParser *opaque);
int gb_markdown_link(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *content, MarkdownParser *opaque);
int gb_markdown_raw_html_tag(struct buf *ob, const struct buf *tag, MarkdownParser *opaque);
int gb_markdown_triple_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
int gb_markdown_strikethrough(struct buf *ob, const struct buf *text, MarkdownParser *opaque);
int gb_markdown_superscript(struct buf *ob, const struct buf *text, MarkdownParser *opaque);

void gb_markdown_entity(struct buf *ob, const struct buf *entity, MarkdownParser *opaque);
void gb_markdown_normal_text(struct buf *ob, const struct buf *text, MarkdownParser *opaque);

void gb_markdown_doc_header(struct buf *ob, MarkdownParser *opaque);
void gb_markdown_doc_footer(struct buf *ob, MarkdownParser *opaque);

#pragma mark -

@interface MarkdownParser ()
@property (nonatomic, assign) BOOL wasAtLeastOneCallbackInvoked;
@end

@implementation MarkdownParser

#pragma mark - Initialization & disposal

- (id)init {
    self = [super init];
    if (self) {
		// If MKDEXT_AUTOLINK enabled, Markdown links aren't working!
        self.parserExtensions = MKDEXT_NO_INTRA_EMPHASIS | MKDEXT_TABLES | MKDEXT_FENCED_CODE | MKDEXT_STRIKETHROUGH | MKDEXT_SPACE_HEADERS | MKDEXT_SUPERSCRIPT | MKDEXT_LAX_SPACING;
		self.bufferAllocationSize = 64;
		self.maximumNesting = 16;
    }
    return self;
}

#pragma mark - Parsing

- (NSString *)parseString:(NSString *)string {
	struct buf *inputBuffer = bufnew(self.bufferAllocationSize);
	struct buf *outputBuffer = bufnew(self.bufferAllocationSize);
	struct sd_markdown *renderer = sd_markdown_new(self.parserExtensions, self.maximumNesting, &gb_markdown_callbacks, (__bridge void *)self);
	[self configureMarkdownCallbacks];

	inputBuffer->data = [string UTF8String];
	inputBuffer->size = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	self.textBeingParsed = inputBuffer->data;
	self.wasAtLeastOneCallbackInvoked = NO;
	
	sd_markdown_render(outputBuffer, inputBuffer->data, inputBuffer->size, renderer);
	sd_markdown_free(renderer);
	NSString *result = [NSString stringWithUTF8String:outputBuffer->data];

	// Sundown in its current incarnation doesn't inform about paragraph if the source string is single line, so we need to manually notify delegate in such case...
	if (!self.wasAtLeastOneCallbackInvoked && [self delegateRespondsToSelector:@selector(markdownParser:parseParagraph:output:)]) {
		[self.delegate markdownParser:self parseParagraph:inputBuffer output:outputBuffer];
	}
	
	self.textBeingParsed = NULL;
	bufrelease(outputBuffer);
	return result;
}

#pragma mark - Helper methods

- (void)configureMarkdownCallbacks {
#define CALLBACK(s, m, f) 	gb_markdown_callbacks.m = [self delegateRespondsToSelector:@selector(s)] ? &f : NULL
	CALLBACK(markdownParser:parseBlockCode:language:output:, blockcode, gb_markdown_blockcode);
	CALLBACK(markdownParser:parseBlockQuote:output:, blockquote, gb_markdown_blockquote);
	CALLBACK(markdownParser:parseBlockHTML:output:, blockhtml, gb_markdown_blockhtml);
	CALLBACK(markdownParser:parseHeader:level:output:, header, gb_markdown_header);
	CALLBACK(markdownParser:parseHRule:, hrule, gb_markdown_hrule);
	CALLBACK(markdownParser:parseList:flags:output:, list, gb_markdown_list);
	CALLBACK(markdownParser:parseListItem:flags:output:, listitem, gb_markdown_listitem);
	CALLBACK(markdownParser:parseParagraph:output:, paragraph, gb_markdown_paragraph);
	CALLBACK(markdownParser:parseTableHeader:body:output:, table, gb_markdown_table);
	CALLBACK(markdownParser:parseTableRow:output:, table_row, gb_markdown_table_row);
	CALLBACK(markdownParser:parseTableCell:flags:output:, table_cell, gb_markdown_table_cell);
	
	CALLBACK(markdownParser:parseAutoLink:type:output:, autolink, gb_markdown_autolink);
	CALLBACK(markdownParser:parseCodeSpan:output:, codespan, gb_markdown_codespan);
	CALLBACK(markdownParser:parseTripleEmphasis:output:, triple_emphasis, gb_markdown_triple_emphasis);
	CALLBACK(markdownParser:parseDoubleEmphasis:output:, double_emphasis, gb_markdown_double_emphasis);
	CALLBACK(markdownParser:parseEmphasis:output:, emphasis, gb_markdown_emphasis);
	CALLBACK(markdownParser:parseImageLink:title:alt:output:, image, gb_markdown_image);
	CALLBACK(markdownParser:parseLineBreak:output:, linebreak, gb_markdown_linebreak);
	CALLBACK(markdownParser:parseLink:title:content:, link, gb_markdown_link);
	CALLBACK(markdownParser:parseRawHTMLTag:output:, raw_html_tag, gb_markdown_raw_html_tag);
	CALLBACK(markdownParser:parseStrikeThrough:output:, strikethrough, gb_markdown_strikethrough);
	CALLBACK(markdownParser:parseSuperScript:output:, superscript, gb_markdown_superscript);
	
	CALLBACK(markdownParser:parseEntity:output:, entity, gb_markdown_entity);
	CALLBACK(markdownParser:parseNormalText:output:, normal_text, gb_markdown_normal_text);
	
	CALLBACK(markdownParser:parseDocHeader:output:, doc_header, gb_markdown_doc_header);
	CALLBACK(markdownParser:parseDocFooter:output:, doc_footer, gb_markdown_doc_footer);
}

- (BOOL)delegateRespondsToSelector:(SEL)selector {
	if (!self.delegate) return NO;
	if (![self.delegate respondsToSelector:selector]) return NO;
	return YES;
}

@end

#pragma mark - Markdown C API callbacks

void gb_markdown_blockcode(struct buf *ob, const struct buf *text, const struct buf *lang, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseBlockCode:text language:lang output:ob];
}

void gb_markdown_blockquote(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseBlockQuote:text output:ob];
}

void gb_markdown_blockhtml(struct buf *ob,const  struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseBlockHTML:text output:ob];
}

void gb_markdown_header(struct buf *ob, const struct buf *text, int level, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseHeader:text level:level output:ob];
}

void gb_markdown_hrule(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseHRule:ob];
}

void gb_markdown_list(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseList:text flags:flags output:ob];
}

void gb_markdown_listitem(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseListItem:text flags:flags output:ob];
}

void gb_markdown_paragraph(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseParagraph:text output:ob];
}

void gb_markdown_table(struct buf *ob, const struct buf *header, const struct buf *body, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableHeader:header body:body output:ob];
}

void gb_markdown_table_row(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableRow:text output:ob];
}

void gb_markdown_table_cell(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableCell:text flags:flags output:ob];
}


int gb_markdown_autolink(struct buf *ob, const struct buf *link, enum mkd_autolink type, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseAutoLink:link type:type output:ob];
}

int gb_markdown_codespan(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseCodeSpan:text output:ob];
}

int gb_markdown_double_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseDoubleEmphasis:text output:ob];
}

int gb_markdown_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseEmphasis:text output:ob];
}

int gb_markdown_image(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseImageLink:link title:title alt:alt output:ob];
}

int gb_markdown_linebreak(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseLineBreak:ob];
}

int gb_markdown_link(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *content, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseLink:link title:title content:content output:ob];
}

int gb_markdown_raw_html_tag(struct buf *ob, const struct buf *tag, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseRawHTMLTag:tag output:ob];
}

int gb_markdown_triple_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseTripleEmphasis:text output:ob];
}

int gb_markdown_strikethrough(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseStrikeThrought:text output:ob];
}

int gb_markdown_superscript(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseSuperScript:text output:ob];
}


void gb_markdown_entity(struct buf *ob, const struct buf *entity, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseEntity:entity output:ob];
}

void gb_markdown_normal_text(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseNormalText:text output:ob];
}


void gb_markdown_doc_header(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseDocHeader:ob];
}

void gb_markdown_doc_footer(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseDocFooter:ob];
}
