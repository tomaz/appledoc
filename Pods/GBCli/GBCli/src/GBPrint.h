//
//  GBPrint.h
//  GBCli
//
//  Created by Tomaz Kragelj on 23.05.14.
//
//

#import <Foundation/Foundation.h>

extern void gbprint(NSString *format, ...);
extern void gbprintln(NSString *format, ...);
extern void gbfprint(FILE *file, NSString *format, ...);
extern void gbfprintln(FILE *file, NSString *format, ...);
