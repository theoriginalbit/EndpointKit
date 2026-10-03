//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPAuthenticationHeaderValue Tests")
struct HTTPAuthenticationHeaderValueTests {
	@Test(.tags(.regression)) func testBearerTokenFormatting() {
		let bearer1 = HTTPAuthenticationHeaderValue.bearer("myToken123")
		#expect(bearer1.value == "Bearer myToken123")

		let bearer2 = HTTPAuthenticationHeaderValue.bearer("Bearer myToken123")
		#expect(bearer2.value == "Bearer myToken123")
	}

	@Test(.tags(.regression)) func testBasicAuthFormatting() {
		let basic = HTTPAuthenticationHeaderValue.basic(username: "user", password: "password")
		let expectedBase64 = Data("user:password".utf8).base64EncodedString()
		#expect(basic.value == "Basic \(expectedBase64)")
	}

	@Test(.tags(.regression)) func testStringLiteralAndEquality() {
		let custom: HTTPAuthenticationHeaderValue = "Bearer rawToken"
		let explicit = HTTPAuthenticationHeaderValue("Bearer rawToken")
		#expect(custom == explicit)
		#expect(custom.value == "Bearer rawToken")
	}
}
