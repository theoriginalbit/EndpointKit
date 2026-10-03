//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPScheme Tests")
struct HTTPSchemeTests {
	@Test(.tags(.regression)) func testPredefinedSchemes() {
		#expect(HTTPScheme.https.rawValue == "https")
		#expect(HTTPScheme.http.rawValue == "http")
		#expect(HTTPScheme.wss.rawValue == "wss")
		#expect(HTTPScheme.ws.rawValue == "ws")
	}

	@Test(.tags(.regression)) func testCustomStringConvertibleAndLiterals() {
		let scheme: HTTPScheme = "ftp"
		#expect(scheme.rawValue == "ftp")
		#expect(scheme.description == "ftp")
		#expect(scheme.debugDescription == "ftp")
		#expect(scheme == HTTPScheme("ftp"))
	}
}
