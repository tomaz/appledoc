#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"
#import "CDRFunctions.h"

#pragma mark - Helpers

BOOL CDRClassIsOfType(Class class, const char * const className) {
    Protocol * protocol = NSProtocolFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]);
    if (strcmp(className, class_getName(class))) {
        while (class) {
            if (class_conformsToProtocol(class, protocol)) {
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

#pragma mark - Globals

void CDRDefineSharedExampleGroups() {
    NSArray *sharedExampleGroupPoolClasses = CDRSelectClasses(^(Class class) {
        return CDRClassIsOfType(class, "CDRSharedExampleGroupPool");
    });

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
    [SpecHelper specHelper].globalBeforeEachClasses = CDRSelectClasses(^BOOL(Class class) {
        return CDRClassHasClassMethod(class, @selector(beforeEach));
    });

    [SpecHelper specHelper].globalAfterEachClasses = CDRSelectClasses(^BOOL(Class class) {
        return CDRClassHasClassMethod(class, @selector(afterEach));
    });
}

#pragma mark - Reporters

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

    NSMutableArray *reporters = [NSMutableArray arrayWithCapacity:reporterClasses.count];
    for (Class reporterClass in reporterClasses) {
        [reporters addObject:[[[reporterClass alloc] init] autorelease]];
    }
    return reporters;
}

#pragma mark - Spec running

NSArray *CDRSpecClassesToRun() {
    char *envSpecClassNames = getenv("CEDAR_SPEC_CLASSES");
    if (envSpecClassNames) {
        NSArray *specClassNames =
            [[NSString stringWithUTF8String:envSpecClassNames]
                componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *specClassesToRun = [NSMutableArray arrayWithCapacity:specClassNames.count];

        for (NSString *className in specClassNames) {
            Class specClass = NSClassFromString(className);
            if (specClass) {
                [specClassesToRun addObject:specClass];
            }
        }
        return [[specClassesToRun copy] autorelease];
    }

    return CDRSelectClasses(^(Class class) {
        return CDRClassIsOfType(class, "CDRSpec");
    });
}

NSArray *CDRSpecsFromSpecClasses(NSArray *specClasses) {
    NSMutableArray *specs = [NSMutableArray arrayWithCapacity:specClasses.count];
    for (Class class in specClasses) {
        CDRSpec *spec = [[[class alloc] init] autorelease];
        [spec defineBehaviors];
        [specs addObject:spec];
    }
    return specs;
}

void CDRMarkFocusedExamplesInSpecs(NSArray *specs) {
    char *envSpecFile = getenv("CEDAR_SPEC_FILE");
    if (envSpecFile) {
        NSArray *components = [[NSString stringWithUTF8String:envSpecFile] componentsSeparatedByString:@":"];

        for (CDRSpec *spec in specs) {
            if ([spec.fileName isEqualToString:[components objectAtIndex:0]]) {
                [spec markAsFocusedClosestToLineNumber:[[components objectAtIndex:1] intValue]];
            }
        }
    }

    for (CDRSpec *spec in specs) {
        SpecHelper.specHelper.shouldOnlyRunFocused |= spec.rootGroup.hasFocusedExamples;
    }
}

NSArray *CDRRootGroupsFromSpecs(NSArray *specs) {
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:specs.count];
    for (CDRSpec *spec in specs) {
        [groups addObject:spec.rootGroup];
    }
    return groups;
}

int runSpecsWithCustomExampleReporters(NSArray *reporters) {
    @autoreleasepool {
        CDRDefineSharedExampleGroups();
        CDRDefineGlobalBeforeAndAfterEachBlocks();

        NSArray *specClasses = CDRSpecClassesToRun();
        NSArray *specs = CDRSpecsFromSpecClasses(specClasses);
        CDRMarkFocusedExamplesInSpecs(specs);

        NSArray *groups = CDRRootGroupsFromSpecs(specs);
        [reporters makeObjectsPerformSelector:@selector(runWillStartWithGroups:) withObject:groups];
        [groups makeObjectsPerformSelector:@selector(run)];

        int result = 0;
        for (id<CDRExampleReporter> reporter in reporters) {
            [reporter runDidComplete];
            result |= [reporter result];
        }
        return result;
    }
}

int runSpecs() {
    @autoreleasepool {
        NSArray *reporters = CDRReportersFromEnv("CDRDefaultReporter");
        if (![reporters count]) {
            @throw @"No reporters?  WTF?";
        }
        return runSpecsWithCustomExampleReporters(reporters);
    }
}

int runAllSpecs() {
    return runSpecs();
}
