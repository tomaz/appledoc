//
//  GBDictionaryTemplateLoader.h
//  appledoc
//
//  Created by Tomaz Kragelj on 19.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "GRMustache.h"

/** Encapsulates template loading with partials provided through a dictionary.
 
 This is almost straight from `GRMustache` example, with just a bit of cleanup and garbage collector modifications. Although the functionality could easily be implemented by `GBTemplateHandler`, it was moved to a separate class to better encapsulate `GRMustache` logic and prevent bloating public interface of `GBTemplateHandler` with all specifics of `GRMustacheTemplateLoader` that are not needed for creating output.
 */
@interface GBDictionaryTemplateLoader : GRMustacheTemplateLoader {
	@private
    NSDictionary *_partials;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBDictionaryTemplateLoader` instance. 
 
 @param partials The dictionary of all partials.
 @return Returns initialized instance.
 */ 
+ (id)loaderWithDictionary:(NSDictionary *)partials;

/** Initializes the template loader with the given dictionary of partials.
 
 @param partials The dictionary of all partials.
 @return Returns initialized instance.
 */
- (id)initWithDictionary:(NSDictionary *)partials;

@end
