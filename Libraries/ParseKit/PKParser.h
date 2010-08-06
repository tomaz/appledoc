//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>

@class PKAssembly;
@class PKTokenizer;

/*!
    @class      PKParser 
    @brief      An Abstract class. A <tt>PKParser</tt> is an object that recognizes the elements of a language.
    @details    <p>Each <tt>PKParser</tt> object is either a <tt>PKTerminal</tt> or a composition of other parsers. The <tt>PKTerminal</tt> class is a subclass of Parser, and is itself a hierarchy of parsers that recognize specific patterns of text. For example, a <tt>PKWord</tt> recognizes any word, and a <tt>PKLiteral</tt> matches a specific string.</p>
                <p>In addition to <tt>PKTerminal</tt>, other subclasses of <tt>PKParser</tt> provide composite parsers, describing sequences, alternations, and repetitions of other parsers. For example, the following <tt>PKParser</tt> objects culminate in a good parser that recognizes a description of good coffee.</p>
@code
    PKAlternation *adjective = [PKAlternation alternation];
    [adjective add:[PKLiteral literalWithString:@"steaming"]];
    [adjective add:[PKLiteral literalWithString:@"hot"]];
    PKSequence *good = [PKSequence sequence];
    [good add:[PKRepetition repetitionWithSubparser:adjective]];
    [good add:[PKLiteral literalWithString:@"coffee"]];
    NSString *s = @"hot hot steaming hot coffee";
    PKAssembly *a = [PKTokenAssembly assemblyWithString:s];
    NSLog([good bestMatchFor:a]);
@endcode
                <p>This prints out:</p>
@code
    [hot, hot, steaming, hot, coffee]
    hot/hot/steaming/hot/coffee^
@endcode
                <p>The parser does not match directly against a string, it matches against a <tt>PKAssembly</tt>. The resulting assembly shows its stack, with four words on it, along with its sequence of tokens, and the index at the end of these. In practice, parsers will do some work on an assembly, based on the text they recognize.</p>
*/
@interface PKParser : NSObject {
#ifdef TARGET_OS_SNOW_LEOPARD
    void (^assemblerBlock)(PKAssembly *);
    void (^preassemblerBlock)(PKAssembly *);
#endif
    id assembler;
    SEL assemblerSelector;
    id preassembler;
    SEL preassemblerSelector;    
    NSString *name;
    PKTokenizer *tokenizer; // PKParserFactoryAdditions ivar
}

/*!
    @brief      Convenience factory method for initializing an autoreleased parser.
    @result     an initialized autoreleased parser.
*/
+ (PKParser *)parser;

/*!
    @brief      Sets the object and method that will work on an assembly whenever this parser successfully matches against the assembly.
    @details    The method represented by <tt>sel</tt> must accept a single <tt>PKAssembly</tt> argument. The signature of <tt>sel</tt> should be similar to: <tt>- (void)didMatchAssembly:(PKAssembly *)a</tt>.
    @param      a the assembler this parser will use to work on an assembly
    @param      sel a selector that assembler <tt>a</tt> responds to which will work on an assembly
*/
- (void)setAssembler:(id)a selector:(SEL)sel;

/*!
    @brief      Sets the object that will work on every assembly before matching against it.
    @details    Setting a preassembler is entirely optional, but sometimes useful for repetition parsers to do work on an assembly before matching against it.
    @param      a the assembler this parser will use to work on an assembly before matching against it.
    @param      sel a selector that assembler <tt>a</tt> responds to which will work on an assembly
*/
- (void)setPreassembler:(id)a selector:(SEL)sel;

/*!
    @brief      Returns the most-matched assembly in a collection.
    @param      inAssembly the assembly for which to find the best match
    @result     an assembly with the greatest possible number of elements consumed by this parser
*/
- (PKAssembly *)bestMatchFor:(PKAssembly *)inAssembly;

/*!
    @brief      Returns either <tt>nil</tt>, or a completely matched version of the supplied assembly.
    @param      inAssembly the assembly for which to find the complete match
    @result     either <tt>nil</tt>, or a completely matched version of the supplied assembly
*/
- (PKAssembly *)completeMatchFor:(PKAssembly *)inAssembly;

/*!
    @brief      Given a set of assemblies, this method matches this parser against all of them, and returns a new set of the assemblies that result from the matches.
    @details    <p>Given a set of assemblies, this method matches this parser against all of them, and returns a new set of the assemblies that result from the matches.</p>
                <p>For example, consider matching the regular expression <tt>a*</tt> against the string <tt>aaab</tt>. The initial set of states is <tt>{^aaab}</tt>, where the <tt>^</tt> indicates how far along the assembly is. When <tt>a*</tt> matches against this initial state, it creates a new set <tt>{^aaab, a^aab, aa^ab, aaa^b}</tt>.</p>
    @param      inAssemblies set of assemblies to match against
    @result     a set of assemblies that result from matching against a beginning set of assemblies
*/
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;

/*!
    @brief      Find a parser with the given name
    @details    Performs a depth-first recursive search (starting with this parser) for a parser or subparser with the given name. If this parser's name is name, it will be returned.
    @param      name of the parser to be found
    @result     the parser with the given name or <tt>nil</tt> if not found
 */
- (PKParser *)parserNamed:(NSString *)name;

#ifdef TARGET_OS_SNOW_LEOPARD
/*!
    @property   assemblerBlock
    @brief      Set a block which should be executed after this parser is matched
    @details    <p>This is an alternative to calling <tt>-setAssembler:selector:</tt>.</p>
                <p>Passing a block to this method will cause this parser to execute the given block after it is matched (rather than sending <tt>assembler</tt> the <tt>assemblerSelector</tt> message.</p>
                <p>Using a block as the assembler will sometimes be more convient than setting an assembler object.</p>
    @param      block of code to be executed after a parser is matched.
*/
@property (nonatomic, retain) void (^assemblerBlock)(PKAssembly *);

/*!
    @property   preassemblerBlock
    @brief      Set a block which should be executed before this parser is matched
    @details    <p>This is an alternative to calling <tt>-setPreassembler:selector:</tt>.</p>
                <p>Passing a block to this method will cause this parser to execute the given block before it is matched (rather than sending <tt>preassembler</tt> the <tt>preassemblerSelector</tt> message.</p>
                <p>Using a block as the preassembler will sometimes be more convient than setting an preassembler object.</p>
    @param      block of code to be executed before a parser is matched.
 */
@property (nonatomic, retain) void (^preassemblerBlock)(PKAssembly *);
#endif

/*!
    @property   assembler
    @brief      The assembler this parser will use to work on a matched assembly.
    @details    <tt>assembler</tt> should respond to the selector held by this parser's <tt>selector</tt> property.
*/
@property (nonatomic, assign) id assembler;

/*!
    @property   assemblerSelector
    @brief      The method of <tt>assembler</tt> this parser will call to work on a matched assembly.
    @details    The method represented by <tt>assemblerSelector</tt> must accept a single <tt>PKAssembly</tt> argument. The signature of <tt>assemblerSelector</tt> should be similar to: <tt>- (void)didMatchFoo:(PKAssembly *)a</tt>.
*/
@property (nonatomic, assign) SEL assemblerSelector;

/*!
    @property   preassembler
    @brief      The assembler this parser will use to work on an assembly before matching against it.
    @discussion <tt>preassembler</tt> should respond to the selector held by this parser's <tt>preassemblerSelector</tt> property.
*/
@property (nonatomic, assign) id preassembler;

/*!
    @property   preAssemlerSelector
    @brief      The method of <tt>preassembler</tt> this parser will call to work on an assembly.
    @details    The method represented by <tt>preassemblerSelector</tt> must accept a single <tt>PKAssembly</tt> argument. The signature of <tt>preassemblerSelector</tt> should be similar to: <tt>- (void)didMatchAssembly:(PKAssembly *)a</tt>.
*/
@property (nonatomic, assign) SEL preassemblerSelector;

/*!
    @property   name
    @brief      The name of this parser.
    @discussion Use this property to help in identifying a parser or for debugging purposes.
*/
@property (nonatomic, copy) NSString *name;
@end

@interface PKParser (PKParserFactoryAdditions)

- (id)parse:(NSString *)s;

- (PKTokenizer *)tokenizer;
@end

