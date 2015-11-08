//
//  Created by Tomaz Kragelj on 20.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

typealias ClassCrossReference = CrossReference<ClassInfo>

/** Describes a class.
*/
class ClassInfo: InterfaceBase {
	
	/// The super class or nil if this is root class.
	lazy var superclass: ClassCrossReference? = nil
	
	/// Array of categories or extensions.
	lazy var categories = [CategoryCrossReference]()
	
	/// Array of adopted protocols or empty array if class doesn't adopt to any protocol.
	lazy var adoptedProtocols = [ProtocolCrossReference]()
		
}
