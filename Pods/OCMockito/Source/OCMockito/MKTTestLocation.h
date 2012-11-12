//
//  OCMockito - MKTTestLocation.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

typedef struct
{
    id testCase;
    const char *fileName;
    int lineNumber;
} MKTTestLocation;


static inline MKTTestLocation MKTTestLocationMake(id test, const char *file, int line)
{
    MKTTestLocation location;
    location.testCase = test;
    location.fileName = file;
    location.lineNumber = line;
    return location;
}

void MKTFailTest(id testCase, const char *fileName, int lineNumber, NSString *description);
void MKTFailTestLocation(MKTTestLocation testLocation, NSString *description);
