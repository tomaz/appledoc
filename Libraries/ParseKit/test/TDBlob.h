//
//  PKBlob.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/7/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>

@interface TDBlob : PKTerminal {

}
+ (id)blob;

+ (id)blobWithStartMarker:(NSString *)s;
@end
