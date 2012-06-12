//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <OCMock/OCMock.h>
#import "OCObserverMockObjectTests.h"

static NSString *TestNotificationOne = @"TestNotificationOne";


@implementation OCObserverMockObjectTest

- (void)setUp
{
	center = [[[NSNotificationCenter alloc] init] autorelease];
	mock = [OCMockObject observerMock]; 
}

- (void)testAcceptsExpectedNotification
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
    
    [center postNotificationName:TestNotificationOne object:self];
	
    [mock verify];
}

- (void)testAcceptsExpectedNotificationWithSpecifiedObjectAndUserInfo
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    [[mock expect] notificationWithName:TestNotificationOne object:self userInfo:info];
    
    [center postNotificationName:TestNotificationOne object:self userInfo:info];
	
    [mock verify];
}

- (void)testAcceptsNotificationsInAnyOrder
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
	[[mock expect] notificationWithName:TestNotificationOne object:self];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
	
	[center postNotificationName:TestNotificationOne object:[NSString string]];
	[center postNotificationName:TestNotificationOne object:self];
}

- (void)testAcceptsNotificationsInCorrectOrderWhenOrderMatters
{
	[mock setExpectationOrderMatters:YES];

	[center addMockObserver:mock name:TestNotificationOne object:nil];
	[[mock expect] notificationWithName:TestNotificationOne object:self];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
	
	[center postNotificationName:TestNotificationOne object:self];
	[center postNotificationName:TestNotificationOne object:[NSString string]];
}

- (void)testRaisesExceptionWhenSequenceIsWrongAndOrderMatters
{
	[mock setExpectationOrderMatters:YES];
	
	[center addMockObserver:mock name:TestNotificationOne object:nil];
	[[mock expect] notificationWithName:TestNotificationOne object:self];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
	
	STAssertThrows([center postNotificationName:TestNotificationOne object:[NSString string]], @"Should have complained about sequence.");
}

- (void)testRaisesEvenThoughOverlappingExpectationsCouldHaveBeenSatisfied
{
	// this test demonstrates a shortcoming, not a feature
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
	[[mock expect] notificationWithName:TestNotificationOne object:self];
	
	[center postNotificationName:TestNotificationOne object:self];
	STAssertThrows([center postNotificationName:TestNotificationOne object:[NSString string]], nil);
}

- (void)testRaisesExceptionWhenUnexpectedNotificationIsReceived
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
	
    STAssertThrows([center postNotificationName:TestNotificationOne object:self], nil);
}

- (void)testRaisesWhenNotificationWithWrongObjectIsReceived
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:self];
	
	STAssertThrows([center postNotificationName:TestNotificationOne object:[NSString string]], nil);
}

- (void)testRaisesWhenNotificationWithWrongUserInfoIsReceived
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:self 
							   userInfo:[NSDictionary dictionaryWithObject:@"foo" forKey:@"key"]];
	STAssertThrows([center postNotificationName:TestNotificationOne object:[NSString string] 
									   userInfo:[NSDictionary dictionaryWithObject:@"bar" forKey:@"key"]], nil);
}

- (void)testRaisesOnVerifyWhenExpectedNotificationIsNotSent
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];

	STAssertThrows([mock verify], nil);
}

- (void)testRaisesOnVerifyWhenNotAllNotificationsWereSent
{
	[center addMockObserver:mock name:TestNotificationOne object:nil];
    [[mock expect] notificationWithName:TestNotificationOne object:[OCMArg any]];
	[[mock expect] notificationWithName:TestNotificationOne object:self];

	[center postNotificationName:TestNotificationOne object:self];
	STAssertThrows([mock verify], nil);
}

@end
