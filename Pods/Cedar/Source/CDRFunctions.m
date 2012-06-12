#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CDRSpec.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"
#import "CDRFunctions.h"

BOOL CDRClassIsOfType(Class class, const char * const className) {
    if (strcmp(className, class_getName(class))) {
        while (class) {
            if (class_conformsToProtocol(class, NSProtocolFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]))) {
                return YES;
            }
            class = class_getSuperclass(class);
        }
    }

    return NO;
}

NSArray *CDRSelectClasses(BOOL (^classSelectionPredicate)(Class class)) {
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    NSMutableArray *selectedClasses = [NSMutableArray array];
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];

        if (classSelectionPredicate(class)) {
            [selectedClasses addObject:class];
        }
    }
    return selectedClasses;
}

NSArray *CDRCreateRootGroupsFromSpecClasses(NSArray *specClasses) {
    NSMutableArray *rootGroups = [[NSMutableArray alloc] initWithCapacity:[specClasses count]];
    for (Class class in specClasses) {
        CDRSpec *spec = [[class alloc] init];
        [spec defineBehaviors];
        [rootGroups addObject:spec.rootGroup];
        [spec release];
    }
    return rootGroups;
}

void CDRDefineSharedExampleGroups() {
    NSArray *sharedExampleGroupPoolClasses = CDRSelectClasses(^(Class class) { return CDRClassIsOfType(class, "CDRSharedExampleGroupPool"); });
    for (Class class in sharedExampleGroupPoolClasses) {
        CDRSharedExampleGroupPool *sharedExampleGroupPool = [[class alloc] init];
        [sharedExampleGroupPool declareSharedExampleGroups];
        [sharedExampleGroupPool release];
    }
}

BOOL CDRClassHasClassMethod(Class class, SEL selector) {
    if (strcmp("UIAccessibilitySafeCategory__NSObject", class_getName(class))) {
        return !!class_getClassMethod(class, selector);
    }
    return NO;
}

void CDRDefineGlobalBeforeAndAfterEachBlocks() {
    [SpecHelper specHelper].globalBeforeEachClasses = CDRSelectClasses(^BOOL(Class class) { return CDRClassHasClassMethod(class, @selector(beforeEach)); });
    [SpecHelper specHelper].globalAfterEachClasses = CDRSelectClasses(^BOOL(Class class) { return CDRClassHasClassMethod(class, @selector(afterEach)); });
}

NSArray *CDRReporterClassesFromEnv(const char *defaultReporterClassName) {
    const char *reporterClassNamesCsv = getenv("CEDAR_REPORTER_CLASS");
    if (!reporterClassNamesCsv) {
        reporterClassNamesCsv = defaultReporterClassName;
    }

    NSString *objCClassNames = [NSString stringWithUTF8String:reporterClassNamesCsv];
    NSArray *reporterClassNames = [objCClassNames componentsSeparatedByString:@","];

    NSMutableArray *reporterClasses = [NSMutableArray arrayWithCapacity:[reporterClassNames count]];
    for (NSString *reporterClassName in reporterClassNames) {
        Class reporterClass = NSClassFromString(reporterClassName);
        if (!reporterClass) {
            printf("***** The specified reporter class \"%s\" does not exist. *****\n", [reporterClassName cStringUsingEncoding:NSUTF8StringEncoding]);
            return nil;
        }
        [reporterClasses addObject:reporterClass];
    }

    return reporterClasses;
}

NSArray *CDRReportersFromEnv(const char *defaultReporterClassName) {
    NSArray *reporterClasses = CDRReporterClassesFromEnv(defaultReporterClassName);

    NSMutableArray *reporters = [NSMutableArray arrayWithCapacity:[reporterClasses count]];
    for (Class reporterClass in reporterClasses) {
        [reporters addObject:[[[reporterClass alloc] init] autorelease]];
    }

    return reporters;
}

NSArray *CDRSpecClassesToRun() {
    char *envSpecClassNames = getenv("CEDAR_SPEC_CLASSES");
    if (envSpecClassNames) {
        NSArray *specClassNames = [[NSString stringWithCString:envSpecClassNames encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *specClassesToRun = [NSMutableArray arrayWithCapacity:[specClassNames count]];
        for (NSString *className in specClassNames) {
            Class specClass = NSClassFromString(className);
            if (specClass) {
                [specClassesToRun addObject:specClass];
            }
        }
        return [[specClassesToRun copy] autorelease];
    }
    return nil;
}

int runSpecsWithCustomExampleReporters(NSArray *reporters) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSArray *specClasses = CDRSpecClassesToRun();
    if (!specClasses) {
        specClasses = CDRSelectClasses(^(Class class) { return CDRClassIsOfType(class, "CDRSpec"); });
    }

    CDRDefineSharedExampleGroups();
    CDRDefineGlobalBeforeAndAfterEachBlocks();
    NSArray *groups = CDRCreateRootGroupsFromSpecClasses(specClasses);

    for (CDRExampleGroup *group in groups) {
        [SpecHelper specHelper].shouldOnlyRunFocused |= [group hasFocusedExamples];
    }

    for (id<CDRExampleReporter> reporter in reporters) {
        [reporter runWillStartWithGroups:groups];
    }

    [groups makeObjectsPerformSelector:@selector(run)];

    int result = 0;
    for (id<CDRExampleReporter> reporter in reporters) {
        [reporter runDidComplete];
        result |= [reporter result];
    }

    [groups release];
    [pool drain];
    return result;
}

int runSpecs() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSArray *reporters = CDRReportersFromEnv("CDRDefaultReporter");
    if (![reporters count]) {
        return -999;
    }

    int result = runSpecsWithCustomExampleReporters(reporters);

    [pool drain];
    return result;
}

int runAllSpecs() {
    return runSpecs();
}
