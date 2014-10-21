//
//  GBPrint.m
//  GBCli
//
//  Created by Tomaz Kragelj on 23.05.14.
//
//

#import "GBPrint.h"

static void gb_printf_worker(FILE *file, NSString *format, va_list arguments) {
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    fprintf(file, "%s", [msg UTF8String]);
}

void gbprint(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
	gb_printf_worker(stdout, format, arguments);
    va_end(arguments);
}

void gbprintln(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
	format = [format stringByAppendingString:@"\n"];
	gb_printf_worker(stdout, format, arguments);
    va_end(arguments);
}

void gbfprint(FILE *file, NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
	gb_printf_worker(file, format, arguments);
    va_end(arguments);
}

void gbfprintln(FILE *file, NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
	format = [format stringByAppendingString:@"\n"];
	gb_printf_worker(file, format, arguments);
    va_end(arguments);
}
