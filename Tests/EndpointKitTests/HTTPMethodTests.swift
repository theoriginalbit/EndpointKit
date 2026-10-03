//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPMethod Tests")
struct HTTPMethodTests {
	@Test(.tags(.regression)) func testStandardMethods() {
		#expect(HTTPMethod.get.rawValue == "GET")
		#expect(HTTPMethod.post.rawValue == "POST")
		#expect(HTTPMethod.put.rawValue == "PUT")
		#expect(HTTPMethod.patch.rawValue == "PATCH")
		#expect(HTTPMethod.delete.rawValue == "DELETE")
	}

	@Test(.tags(.regression)) func testStringLiteralInitialization() {
		let customMethod: HTTPMethod = "CUSTOM_VERB"
		#expect(customMethod.rawValue == "CUSTOM_VERB")
		#expect(customMethod.description == "CUSTOM_VERB")
	}
}
