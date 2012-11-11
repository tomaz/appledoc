//
//  MarkdownParser.m
//  appledoc
//
//  Created by Tomaz Kragelj on 8/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Logging.h"
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
@property (nonatomic, assign) id parsingContext; // don't need strong here; context should only be kept alive during parsing.
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

static uint8_t thebuffer;
- (NSString *)parseString:(NSString *)string context:(id)context {
	struct buf *inputBuffer = bufnew(self.bufferAllocationSize);
	struct buf *outputBuffer = bufnew(self.bufferAllocationSize);
	struct sd_markdown *renderer = sd_markdown_new(self.parserExtensions, self.maximumNesting, &gb_markdown_callbacks, (__bridge void *)self);
	[self configureMarkdownCallbacks];

	inputBuffer->data = [string UTF8String];
	inputBuffer->size = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	thebuffer = inputBuffer->data;
	self.textBeingParsed = inputBuffer->data;
	self.wasAtLeastOneCallbackInvoked = NO;
	self.parsingContext = context;
	
	sd_markdown_render(outputBuffer, inputBuffer->data, inputBuffer->size, renderer);
	sd_markdown_free(renderer);
	NSString *result = [NSString stringWithUTF8String:outputBuffer->data];

	// Sundown in its current incarnation doesn't inform about paragraph if the source string is single line, so we need to manually notify delegate in such case...
	if (!self.wasAtLeastOneCallbackInvoked && [self delegateRespondsToSelector:@selector(markdownParser:parseParagraph:output:context:)]) {
		[self.delegate markdownParser:self parseParagraph:inputBuffer output:outputBuffer context:context];
	}
	
	self.textBeingParsed = NULL;
	bufrelease(outputBuffer);
	return result;
}

- (NSString *)stringFromBuffer:(const struct buf *)buffer {
	if (!buffer || buffer->size == 0) return @"";
	uint8_t *str = malloc(buffer->size + 1);
	if (!str) {
		LogError(@"Failed allocating %lu bytes for converting C string to NSString!", buffer->size);
		return nil;
	}
	memcpy(str, buffer->data, buffer->size);
	str[buffer->size] = 0;
	return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
}

#pragma mark - Helper methods

- (void)configureMarkdownCallbacks {
#define CALLBACK(s, m, f) 	gb_markdown_callbacks.m = [self delegateRespondsToSelector:@selector(s)] ? &f : NULL
	CALLBACK(markdownParser:parseBlockCode:language:output:context:, blockcode, gb_markdown_blockcode);
	CALLBACK(markdownParser:parseBlockQuote:output:context:, blockquote, gb_markdown_blockquote);
	CALLBACK(markdownParser:parseBlockHTML:output:context:, blockhtml, gb_markdown_blockhtml);
	CALLBACK(markdownParser:parseHeader:level:output:context:, header, gb_markdown_header);
	CALLBACK(markdownParser:parseHRule:context:, hrule, gb_markdown_hrule);
	CALLBACK(markdownParser:parseList:flags:output:context:, list, gb_markdown_list);
	CALLBACK(markdownParser:parseListItem:flags:output:context:, listitem, gb_markdown_listitem);
	CALLBACK(markdownParser:parseParagraph:output:context:, paragraph, gb_markdown_paragraph);
	CALLBACK(markdownParser:parseTableHeader:body:output:context:, table, gb_markdown_table);
	CALLBACK(markdownParser:parseTableRow:output:context:, table_row, gb_markdown_table_row);
	CALLBACK(markdownParser:parseTableCell:flags:output:context:, table_cell, gb_markdown_table_cell);
	
	CALLBACK(markdownParser:parseAutoLink:type:output:context:, autolink, gb_markdown_autolink);
	CALLBACK(markdownParser:parseCodeSpan:output:context:, codespan, gb_markdown_codespan);
	CALLBACK(markdownParser:parseTripleEmphasis:output:context:, triple_emphasis, gb_markdown_triple_emphasis);
	CALLBACK(markdownParser:parseDoubleEmphasis:output:context:, double_emphasis, gb_markdown_double_emphasis);
	CALLBACK(markdownParser:parseEmphasis:output:context:, emphasis, gb_markdown_emphasis);
	CALLBACK(markdownParser:parseImageLink:title:alt:output:context:, image, gb_markdown_image);
	CALLBACK(markdownParser:parseLineBreak:output:context:, linebreak, gb_markdown_linebreak);
	CALLBACK(markdownParser:parseLink:title:content:context:, link, gb_markdown_link);
	CALLBACK(markdownParser:parseRawHTMLTag:output:context:, raw_html_tag, gb_markdown_raw_html_tag);
	CALLBACK(markdownParser:parseStrikeThrough:output:context:, strikethrough, gb_markdown_strikethrough);
	CALLBACK(markdownParser:parseSuperScript:output:context:, superscript, gb_markdown_superscript);
	
	CALLBACK(markdownParser:parseEntity:output:context:, entity, gb_markdown_entity);
	CALLBACK(markdownParser:parseNormalText:output:context:, normal_text, gb_markdown_normal_text);
	
	CALLBACK(markdownParser:parseDocHeader:output:context:, doc_header, gb_markdown_doc_header);
	CALLBACK(markdownParser:parseDocFooter:output:context:, doc_footer, gb_markdown_doc_footer);
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
	[opaque.delegate markdownParser:opaque parseBlockCode:text language:lang output:ob context:opaque.parsingContext];
}

void gb_markdown_blockquote(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseBlockQuote:text output:ob context:opaque.parsingContext];
}

void gb_markdown_blockhtml(struct buf *ob,const  struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseBlockHTML:text output:ob context:opaque.parsingContext];
}

void gb_markdown_header(struct buf *ob, const struct buf *text, int level, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseHeader:text level:level output:ob context:opaque.parsingContext];
}

void gb_markdown_hrule(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseHRule:ob context:opaque.parsingContext];
}

void gb_markdown_list(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseList:text flags:flags output:ob context:opaque.parsingContext];
}

void gb_markdown_listitem(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseListItem:text flags:flags output:ob context:opaque.parsingContext];
}

void gb_markdown_paragraph(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseParagraph:text output:ob context:opaque.parsingContext];
}

void gb_markdown_table(struct buf *ob, const struct buf *header, const struct buf *body, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableHeader:header body:body output:ob context:opaque.parsingContext];
}

void gb_markdown_table_row(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableRow:text output:ob context:opaque.parsingContext];
}

void gb_markdown_table_cell(struct buf *ob, const struct buf *text, int flags, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseTableCell:text flags:flags output:ob context:opaque.parsingContext];
}


int gb_markdown_autolink(struct buf *ob, const struct buf *link, enum mkd_autolink type, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseAutoLink:link type:type output:ob context:opaque.parsingContext];
}

int gb_markdown_codespan(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseCodeSpan:text output:ob context:opaque.parsingContext];
}

int gb_markdown_double_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseDoubleEmphasis:text output:ob context:opaque.parsingContext];
}

int gb_markdown_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseEmphasis:text output:ob context:opaque.parsingContext];
}

int gb_markdown_image(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseImageLink:link title:title alt:alt output:ob context:opaque.parsingContext];
}

int gb_markdown_linebreak(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseLineBreak:ob context:opaque.parsingContext];
}

int gb_markdown_link(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *content, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseLink:link title:title content:content output:ob context:opaque.parsingContext];
}

int gb_markdown_raw_html_tag(struct buf *ob, const struct buf *tag, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseRawHTMLTag:tag output:ob context:opaque.parsingContext];
}

int gb_markdown_triple_emphasis(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseTripleEmphasis:text output:ob context:opaque.parsingContext];
}

int gb_markdown_strikethrough(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseStrikeThrought:text output:ob context:opaque.parsingContext];
}

int gb_markdown_superscript(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	return [opaque.delegate markdownParser:opaque parseSuperScript:text output:ob context:opaque.parsingContext];
}


void gb_markdown_entity(struct buf *ob, const struct buf *entity, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseEntity:entity output:ob context:opaque.parsingContext];
}

void gb_markdown_normal_text(struct buf *ob, const struct buf *text, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseNormalText:text output:ob context:opaque.parsingContext];
}


void gb_markdown_doc_header(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseDocHeader:ob context:opaque.parsingContext];
}

void gb_markdown_doc_footer(struct buf *ob, MarkdownParser *opaque) {
	opaque.wasAtLeastOneCallbackInvoked = YES;
	[opaque.delegate markdownParser:opaque parseDocFooter:ob context:opaque.parsingContext];
}
