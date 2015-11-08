//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

extension String {
	
	func stringByAppendingPathComponent(path: String) -> String {
		return (self as NSString).stringByAppendingPathComponent(path)
	}
	
	func stringByAppendingPathExtension(ext: String) -> String? {
		return (self as NSString).stringByAppendingPathExtension(ext)
	}
	
	var lastPathComponent: String {
		return (self as NSString).lastPathComponent
	}
	
	var pathExtension: String {
		return (self as NSString).pathExtension
	}
	
	var stringByStandardizingPath: String {
		return (self as NSString).stringByStandardizingPath
	}
	
	var stringByDeletingLastPathComponent: String {
		return (self as NSString).stringByDeletingLastPathComponent
	}
	
	var stringByDeletingPathExtension: String {
		return (self as NSString).stringByDeletingPathExtension
	}
	
	var pathComponents: [String] {
		return (self as NSString).pathComponents
	}

}