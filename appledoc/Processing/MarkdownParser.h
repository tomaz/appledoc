//
//  MarkdownParser.h
//  appledoc
//
//  Created by Tomaz Kragelj on 8/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#include "markdown.h"
#include "buffer.h"

@protocol MarkdownParserDelegate;

/** Simple object wrapper over sundown parser.
 
 To use, create an instance and assign delegate, then give it an input string and parse options (from sundown) and implement needed protocol methods. Note that implementation is very simple and tries to be as optimal as possible. As a result parameters from sundown C callbacks are passed directly to delegate without boxing into Foundation objects.
 
 @warning **Implementation detail:** Note that the class internally sets up sundown callbacks and all the rest of the structures needed for parsing session. If needed, you can access these through properties from inside delegate callbacks. Also note that at the start of parsing, only sundown callbacks corresponding to implemented delegate methods are assigned. This keeps original implementation to as great degree as possible.
 */
@interface MarkdownParser : NSObject

- (NSString *)parseString:(NSString *)string context:(id)context;

- (NSString *)stringFromBuffer:(const struct buf *)buffer;

@property (nonatomic, assign) uint8_t *textBeingParsed;
@property (nonatomic, assign) NSInteger parserExtensions;
@property (nonatomic, assign) NSUInteger bufferAllocationSize;
@property (nonatomic, assign) NSUInteger maximumNesting;
@property (nonatomic, weak) id<MarkdownParserDelegate> delegate;

@end

#pragma mark - 

@protocol MarkdownParserDelegate <NSObject>

@optional

// Block level callbacks - if not implemented, skips the block
- (void)markdownParser:(MarkdownParser *)parser parseBlockCode:(const struct buf *)text language:(const struct buf *)language output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseBlockQuote:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseBlockHTML:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseHeader:(const struct buf *)text level:(NSInteger)level output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseHRule:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseList:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseListItem:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseParagraph:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseTableHeader:(const struct buf *)header body:(const struct buf *)body output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseTableRow:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseTableCell:(const struct buf *)text flags:(NSInteger)flags output:(struct buf *)buffer context:(id)context;

// Span level callbacks - if not implemented or returns 0, prints span verbatim
- (NSInteger)markdownParser:(MarkdownParser *)parser parseAutoLink:(const struct buf *)link type:(enum mkd_autolink)type output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseCodeSpan:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseTripleEmphasis:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseDoubleEmphasis:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseEmphasis:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseImageLink:(const struct buf *)link title:(const struct buf *)title alt:(const struct buf *)alt output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseLineBreak:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseLink:(const struct buf *)link title:(const struct buf *)title content:(const struct buf *)content output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseRawHTMLTag:(const struct buf *)tag output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseStrikeThrought:(const struct buf *)text output:(struct buf *)buffer context:(id)context;
- (NSInteger)markdownParser:(MarkdownParser *)parser parseSuperScript:(const struct buf *)text output:(struct buf *)buffer context:(id)context;

// Low level callbacks - if not implemented, copies directly into output
- (void)markdownParser:(MarkdownParser *)parser parseEntity:(const struct buf *)entity output:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseNormalText:(const struct buf *)text output:(struct buf *)buffer context:(id)context;

// Header and footer
- (void)markdownParser:(MarkdownParser *)parser parseDocHeader:(struct buf *)buffer context:(id)context;
- (void)markdownParser:(MarkdownParser *)parser parseDocFooter:(struct buf *)buffer context:(id)context;

@end
