//
//  DDXcodeProjectFile.m
//  appledoc
//
//  Created by Dominik Pich on 9/4/12.
//  Copyright (c) 2012 Gentle Bytes. All rights reserved.
//

#import "DDXcodeProjectFile.h"

@interface DDXcodeProjectFile () {
    NSMutableArray *_mutableFilesBuffer;
}

@property(readwrite) NSString *path;
@property(readwrite) NSDictionary *dictionary;

@property(readwrite) NSString *name;
@property(readwrite) NSString *minimumVersion;
@property(readwrite) NSString *projectRoot;
@property(readwrite) NSString *company;
@property(readwrite) NSString *classPrefix;
@property(readwrite) NSString *developmentRegion;
@property(readwrite) NSArray *files;

- (BOOL)parse:(NSError**)pError;

- (id)initWithPath:(NSString*)path;
- (id)initWithName:(NSString*)name andDictionary:(NSDictionary*)dict;
@end

@implementation DDXcodeProjectFile

#pragma mark -

- (id)initWithPath:(NSString*)path {
    id pbxpath = nil;
    
    if([[path lastPathComponent] isEqualToString:@"project.pbxproj"]) {
        pbxpath = path;
        path = path.stringByDeletingLastPathComponent;
    }
    else {
        //path = path
        pbxpath = [path stringByAppendingPathComponent:@"project.pbxproj"];
    }
    
    BOOL isDir = NO;
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir], @"project doesnt exist");
    NSAssert(isDir, @"project should be a directory");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:pbxpath isDirectory:nil], @"project has no pbx xml file");
    
    if(self) {
        self.path = pbxpath;
        self.name = path.lastPathComponent.stringByDeletingPathExtension;
    }
    
    return self;
}

- (id)initWithName:(NSString*)name andDictionary:(NSDictionary*)dict {
    self = [super init];
    
    if(self) {
        self.name = name;
        self.dictionary = dict;
    }
    
    return self;
}

+ (id)xcodeProjectFileWithPath:(NSString*)path error:(NSError**)pError {
    id file = [[[self class] alloc] initWithPath:path];
    if(file) {
        if([file parse:pError]) {
            return file;
        }
    }
    return nil;
}

+ (id)xcodeProjectFileWithDictionary:(NSDictionary*)dict error:(NSError**)pError {
    id file = [[[self class] alloc] initWithDictionary:dict];
    if(file) {
        if([file parse:pError]) {
            return file;
        }
    }
    return nil;
}

#pragma mark - main parse

- (BOOL)parse:(NSError**)pError {
    NSAssert(self.path.length || self.dictionary.count, @"we should have a non-empty path or non-empty dictionary");
    
    //get initial dictionary
    if(self.path.length) {
        self.dictionary = [NSDictionary dictionaryWithContentsOfFile:self.path];
        if(!self.dictionary) {
            if(pError)
                *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:@"cannot make plist from file contents"}];
            return NO;
        }
    }
    if(!self.dictionary) {
        if(pError)
            *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:@"cannot make plist from file contents"}];
        return NO;
    }
    
    //get main objects dictionary
    NSDictionary *objects = self.dictionary[@"objects"];
    if(![objects isKindOfClass:[NSDictionary class]]) {
        if(pError)
            *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:@"cannot find main objects dictionary"}];
        return NO;
    }
    
    //set up _mutableFilesBuffer which will get filled in the parsing process.. or not :D
    _mutableFilesBuffer = [NSMutableArray arrayWithCapacity:objects.count/2];
    
    //handle each object that can appear in a method found via string to SEL
    for (NSDictionary *object in objects.allValues) {
        if(![object isKindOfClass:[NSDictionary class]] || !object[@"isa"]) {
            if(pError)
                *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"cannot handle object %@", object]}];
            return NO;
        }
            
        //get method by isa
        SEL method = [self methodNameForIsa:object[@"isa"]];
        if(!method) {
            if(pError)
                *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"cannot handle isa %@. Selector: %@", object[@"isa"], NSStringFromSelector(method)]}];
            return NO;
        }
        
        //if it doesnt respond to the method, log it and continue for now
        if(![self respondsToSelector:method]) {
            NSLog(@"Warn: dont handle %@", NSStringFromSelector(method));
            continue;
        }
        
        //call the reflected method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSError *suberror = [self performSelector:method withObject:object];
#pragma clang diagnostic pop

        //exit on error
        if(suberror) {
            if(pError)
                *pError = suberror;
            return NO;
        }
    }
    
    //check mandatory... 1 file at least
    if( !_mutableFilesBuffer.count ) {
        if(pError)
            *pError = [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:@"cannot find manatory attributes in plist from file contents"}];
        return NO;
    }
    
    //resolve all
    NSError *suberror = [self resolveFiles:_mutableFilesBuffer];
    if(suberror) {
        if(pError)
            *pError = suberror;
        return NO;
    }
    
    //save buffer to property
    self.files = [NSArray arrayWithArray:_mutableFilesBuffer];

    return YES;
}

- (SEL)methodNameForIsa:(NSString*)pbxIsa {
    NSString *name = [NSString stringWithFormat:@"parse%@:", pbxIsa];
    return NSSelectorFromString(name);
}

- (NSError*)resolveFiles:(NSMutableArray*)files {
    
    return nil;
}

#pragma mark - parse individual objects

//- (NSError*)parsePBXBuildFile:(NSDictionary*)dict {
//    return nil;
//}
//- (NSError*)parsePBXSourcesBuildPhase:(NSDictionary*)dict {
//    return nil;
//}

// we only care about those for now

- (NSError*)parsePBXProject:(NSDictionary*)dict {
    if(!dict[@"attributes"]) {
        return [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"PBXProject without attributes: %@", dict]}];
    }

    self.classPrefix = dict[@"attributes"][@"CLASSPREFIX"];
    self.company = dict[@"attributes"][@"ORGANIZATIONNAME"];
    self.developmentRegion = dict[@"developmentRegion"];
    self.minimumVersion = dict[@"compatibilityVersion"];

    if(dict[@"projectRoot"]) {
        if(self.path.length)
            self.projectRoot = [self.path.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent stringByAppendingPathComponent:dict[@"projectRoot"]];
        else
            self.projectRoot =  dict[@"projectRoot"];
    }
    
    if(!self.company || !self.projectRoot) {
        return [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"PBXProject missing mandatory attributes: %@", dict]}];
    }
    
    return nil;
}

- (NSError*)parsePBXFileReference:(NSDictionary*)dict {
    if(!dict[@"lastKnownFileType"] && dict[@"explicitFileType"]) {
        NSMutableDictionary *mdict = dict.mutableCopy;
        mdict[@"lastKnownFileType"] = dict[@"explicitFileType"];
        dict = mdict;
    }
    
    if(!dict[@"path"] || !dict[@"lastKnownFileType"]) {
        return [NSError errorWithDomain:@"DDXcodeProjectFile" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"PBXFileReference without path/type: %@", dict]}];
    }
    
    //add the path - TO BE resolved later :D
    [_mutableFilesBuffer addObject:@{@"path": dict[@"path"], @"type": dict[@"lastKnownFileType"]}];
    
    return nil; //no error
}

@end
