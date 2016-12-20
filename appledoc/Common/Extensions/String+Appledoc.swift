//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

extension String {
	
	func stringByAppendingPathComponent(_ path: String) -> String {
		return (self as NSString).appendingPathComponent(path)
	}
	
	func stringByAppendingPathExtension(_ ext: String) -> String? {
		return (self as NSString).appendingPathExtension(ext)
	}
	
	var lastPathComponent: String {
		return (self as NSString).lastPathComponent
	}
	
	var pathExtension: String {
		return (self as NSString).pathExtension
	}
	
	var stringByStandardizingPath: String {
		return (self as NSString).standardizingPath
	}
	
	var stringByDeletingLastPathComponent: String {
		return (self as NSString).deletingLastPathComponent
	}
	
	var stringByDeletingPathExtension: String {
		return (self as NSString).deletingPathExtension
	}
	
	var pathComponents: [String] {
		return (self as NSString).pathComponents
	}

}
