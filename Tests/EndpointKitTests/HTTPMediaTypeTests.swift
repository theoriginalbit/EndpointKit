//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPMediaType Tests")
struct HTTPMediaTypeTests {
	@Test(.tags(.regression)) func testStandardMediaTypes() {
		#expect(HTTPMediaType.json.rawValue == "application/json")
		#expect(HTTPMediaType.xml.rawValue == "application/xml")
		#expect(HTTPMediaType.html.rawValue == "text/html")
		#expect(HTTPMediaType.plainText.rawValue == "text/plain")
		#expect(HTTPMediaType.formURLEncoded.rawValue == "application/x-www-form-urlencoded")
		#expect(HTTPMediaType.multipartFormData.rawValue == "multipart/form-data")
		#expect(HTTPMediaType.octetStream.rawValue == "application/octet-stream")
	}

	@Test(.tags(.regression)) func testStringLiteralAndDescription() {
		let custom: HTTPMediaType = "application/custom+json"
		#expect(custom.rawValue == "application/custom+json")
		#expect(custom.description == "application/custom+json")
	}
}
