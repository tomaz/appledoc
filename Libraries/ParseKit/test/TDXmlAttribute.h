//
//  PKXmlAttribute.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTerminal.h"

@interface TDXmlAttribute : TDXmlTerminal {

}
+ (id)attribute;
+ (id)attributeWithString:(NSString *)s;
@end
