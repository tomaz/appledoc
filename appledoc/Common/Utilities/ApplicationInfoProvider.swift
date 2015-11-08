//
//  Created by Tomaz Kragelj on 9.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Provides common information about application to the rest of the application.

This handles things like reverse domain, version, build number etc.
*/
class ApplicationInfoProvider {

	static let sharedInstance = ApplicationInfoProvider()
	
	var reverseDomain: String {
		return "com.gentlebytes.appledoc"
	}
	
	var version: String {
		return GAppledocVersion
	}
	
	var build: String {
		return "\(GAppledocBuildNumber)"
	}
}

