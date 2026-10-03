//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPStatusCode Tests")
struct HTTPStatusCodeTests {
	@Test(.tags(.regression)) func testStatusCodeRanges() {
		let informational = HTTPStatusCode(rawValue: 100) // 100 Continue
		#expect(informational.isInformational)
		#expect(!informational.isSuccess)

		let ok = HTTPStatusCode.ok
		#expect(ok.isSuccess)
		#expect(!ok.isClientError)

		let movedPermanently = HTTPStatusCode.movedPermanently
		#expect(movedPermanently.isRedirection)

		let badRequest = HTTPStatusCode.badRequest
		#expect(badRequest.isClientError)

		let serverError = HTTPStatusCode.internalServerError
		#expect(serverError.isServerError)
	}

	@Test(.tags(.regression)) func testCheckedInitializer() {
		#expect(HTTPStatusCode(checkedValue: 200) != nil)
		#expect(HTTPStatusCode(checkedValue: 99) == nil)
		#expect(HTTPStatusCode(checkedValue: 600) == nil)
	}

	@Test(.tags(.regression)) func testCustomStringConvertible() {
		let code = HTTPStatusCode.ok
		#expect(code.description == "200")
		#expect(code.debugDescription == "200")
	}
}
