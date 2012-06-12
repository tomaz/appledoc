#import "CDRExampleBase.h"
#import "CDRSpecFailure.h"

@interface CDRExample : CDRExampleBase {
    CDRSpecBlock block_;
    CDRExampleState state_;
    CDRSpecFailure *failure_;
}

@property (nonatomic, retain) CDRSpecFailure *failure;

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block;
- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block;

@end
