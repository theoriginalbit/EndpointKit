//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPClient Tests")
struct HTTPClientTests {
	@Test(.tags(.regression)) func testDefaultInitialization() {
		let client = HTTPClient(host: "api.example.com")
		#expect(client.scheme == .https)
		#expect(client.host == "api.example.com")
		#expect(client.port == nil)
		#expect(client.basePath == nil)
		#expect(client.headers.isEmpty)
		#expect(client.timeoutInterval == nil)
	}
}
