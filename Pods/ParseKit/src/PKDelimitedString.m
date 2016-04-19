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

#import <ParseKit/PKDelimitedString.h>
#import <ParseKit/PKToken.h>

@interface PKDelimitedString ()
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end

@implementation PKDelimitedString

+ (PKDelimitedString *)delimitedString {
    return [self delimitedStringWithStartMarker:nil];
}


+ (PKDelimitedString *)delimitedStringWithStartMarker:(NSString *)start {
    return [self delimitedStringWithStartMarker:start endMarker:nil];
}


+ (PKDelimitedString *)delimitedStringWithStartMarker:(NSString *)start endMarker:(NSString *)end {
    PKDelimitedString *ds = [[[self alloc] initWithString:nil] autorelease];
    ds.startMarker = start;
    ds.endMarker = end;
    return ds;
}


- (void)dealloc {
    self.startMarker = nil;
    self.endMarker = nil;
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;
    BOOL result = tok.isDelimitedString;
    if (result && [startMarker length]) {
        result = [tok.stringValue hasPrefix:startMarker];
        if (result && [endMarker length]) {
            result = [tok.stringValue hasSuffix:endMarker];
        }
    }
    return result;
}

@synthesize startMarker;
@synthesize endMarker;
@end