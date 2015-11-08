//
//  Created by Tomaz Kragelj on 21.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

typealias ProtocolCrossReference = CrossReference<ProtocolInfo>

/** Describes a protocol.
*/
class ProtocolInfo {
	
	/// Array of adopted protocols or empty array if protocol doesn't adopt any other protocol.
	lazy var adoptedProtocols = [ProtocolCrossReference]()
	
}
