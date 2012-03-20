@implementation MyClass

@synthesize value1; ///< Can comment here

#pragma mark - Methods group 1

- (id)doSomethingWith:(id)value1 forSomethingElse:(id)value2 {
	if (YES) {
		if (NO) {
			whole;
			[self rest:^{
				ofMamboJumbo = ignored;
			}];
		}
	} else {
	}
	return nil;
}

- (void)methodWithVarArgs:(id)first, ... { }

#pragma mark - Group from implementation

/** Have comment here! */
- (void)method2 { }

@end

#pragma mark - 

@implementation AClass (ACategory)

#pragma mark -
#pragma mark Group
#pragma mark - 

- (id)methodFromCategory {}

@end

#pragma mark - 

const struct GBStruct GBStruct = {
	.value1 = @"value1",
	.value2 = @"value2",
};

NSString *GBConstant1 = @"1";

id function1(id p1, id p2) {
	if () {
		switch () {
		}
	}
	return nil;
}
