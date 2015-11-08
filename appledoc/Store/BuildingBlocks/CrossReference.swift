//
//  Created by Tomaz Kragelj on 21.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Describes a cross reference to another object.

In order to reuse the class, it's implemented as generic; it can reference any type of object.

Note this class describes a "potential" cross reference. It's used during parsing where the whole object graph is not yet known; at the time, only name to related object is given which is later used to provide a link to the actual object.
*/
class CrossReference<T> {
	
	/// The name of the related object.
	lazy var name = ""
	
	/// The actual referenced object which may or may not be available.
	lazy var object: T? = nil
	
}
