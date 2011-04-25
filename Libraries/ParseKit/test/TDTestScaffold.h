//
//  PKTestScaffold.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import <ParseKit/ParseKit.h>

#define TDTrue(e) STAssertTrue((e), @"")
#define TDFalse(e) STAssertFalse((e), @"")
#define TDNil(e) STAssertNil((e), @"")
#define TDNotNil(e) STAssertNotNil((e), @"")
#define TDEquals(e1, e2) STAssertEquals((e1), (e2), @"")
#define TDEqualObjects(e1, e2) STAssertEqualObjects((e1), (e2), @"")
