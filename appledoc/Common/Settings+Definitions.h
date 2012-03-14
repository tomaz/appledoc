//
//  Settings+Definitions.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

typedef NSUInteger GBOptionFlags;

/** Description of a single option or separator. */
typedef struct {
	char shortOption; ///< Short option char or `0` if not used.
	__unsafe_unretained NSString *longOption; ///< Long option name - required for options.
	__unsafe_unretained NSString *description; ///< Description of the option.
	GBOptionFlags flags; ///< Various flags.
} GBOptionDefinition;

/** Various option flags. You can also use GBValueRequirement values here! */
enum {
	GBOptionSeparator = 1 << 3, ///< Option is separator, not real option definition.
	GBOptionNoCmdLine = 1 << 4, ///< Option is only used by global or project settings, not on command line.
	GBOptionNoPrint = 1 << 5, ///< Option should be excluded from print settings display.
	GBOptionNoHelp = 1 << 6, ///< Option should be excluded from help display.
	GBOptionInvisible = GBOptionNoPrint | GBOptionNoHelp,
};

/** The array of all possible options. */
extern GBOptionDefinition GBOptionDefinitions[];

extern inline void GBEnumerateOptions(void(^handler)(GBOptionDefinition *option, BOOL *stop));
extern inline NSUInteger GBOptionRequirements(GBOptionDefinition *option);
extern inline BOOL GBOptionIsSeparator(GBOptionDefinition *option);
extern inline BOOL GBOptionIsCmdLine(GBOptionDefinition *option);
extern inline BOOL GBOptionIsPrint(GBOptionDefinition *option);
extern inline BOOL GBOptionIsHelp(GBOptionDefinition *option);
