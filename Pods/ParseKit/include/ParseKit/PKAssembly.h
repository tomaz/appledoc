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

/*!
    @class      PKAssembly 
    @brief      An Abstract class. A <tt>PKAssembly</tt> maintains a stream of language elements along with stack and target objects.
    @details    <p>Parsers use assemblers to record progress at recognizing language elements from assembly's string.</p>
                <p>Note that <tt>PKAssembly</tt> is an abstract class and may not be instantiated directly. Subclasses include <tt>PKTokenAssembly</tt> and <tt>PKCharAssembly</tt>.</p>
*/
@interface PKAssembly : NSObject <NSCopying> {
    NSMutableArray *stack;
    id target;
    NSUInteger index;
    NSString *string;
    NSString *defaultDelimiter;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased assembly.
    @param      s string to be worked on
    @result     an initialized autoreleased assembly
*/
+ (PKAssembly *)assemblyWithString:(NSString *)s;

/*!
    @brief      Designated Initializer. Initializes an assembly with a given string.
    @details    Designated Initializer.
    @param      s string to be worked on
    @result     an initialized assembly
*/
- (id)initWithString:(NSString *)s;

/*!
    @brief      Removes the object at the top of this assembly's stack and returns it.
    @details    Note this returns an object from this assembly's stack, not from its stream of elements (tokens or chars depending on the type of concrete <tt>PKAssembly</tt> subclass of this object).
    @result     the object at the top of this assembly's stack
*/
- (id)pop;

/*!
    @brief      Pushes an object onto the top of this assembly's stack.
    @param      object object to push
*/
- (void)push:(id)object;

/*!
    @brief      Returns true if this assembly's stack is empty.
    @result     true, if this assembly's stack is empty
*/
- (BOOL)isStackEmpty;

/*!
    @brief      Returns a vector of the elements on this assembly's stack that appear before a specified fence.
    @details    <p>Returns a vector of the elements on this assembly's stack that appear before a specified fence.</p>
                <p>Sometimes a parser will recognize a list from within a pair of parentheses or brackets. The parser can mark the beginning of the list with a fence, and then retrieve all the items that come after the fence with this method.</p>
    @param      fence object that indicates the limit of elements returned from this assembly's stack
    @result     Array of the elements above the specified fence
*/
- (NSArray *)objectsAbove:(id)fence;

/*!
    @property   stack
    @brief      This assembly's stack.
*/
@property (nonatomic, readonly, retain) NSMutableArray *stack;

/*!
    @property   target
    @brief      This assembly's target.
    @details    The object identified as this assembly's "target". Clients can set and retrieve a target, which can be a convenient supplement as a place to work, in addition to the assembly's stack. For example, a parser for an HTML file might use a web page object as its "target". As the parser recognizes markup commands like &lt;head>, it could apply its findings to the target.
*/
@property (nonatomic, retain) id target;
@end
