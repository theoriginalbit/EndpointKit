//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPHeader & HTTPHeaders Tests")
struct HTTPHeaderTests {
	@Test(.tags(.regression)) func testHeaderBuilders() {
		let accept = HTTPHeader.accept(.json)
		#expect(accept.name == "Accept")
		#expect(accept.value == "application/json")

		let contentType = HTTPHeader.contentType(.json)
		#expect(contentType.name == "Content-Type")
		#expect(contentType.value == "application/json")

		let customAccept = HTTPHeader.accept(.xml)
		#expect(customAccept.name == "Accept")
		#expect(customAccept.value == "application/xml")

		let stringAccept = HTTPHeader.accept("application/pdf")
		#expect(stringAccept.name == "Accept")
		#expect(stringAccept.value == "application/pdf")

		let bearer = HTTPHeader.authorization(.bearer("xyz123"))
		#expect(bearer.name == "Authorization")
		#expect(bearer.value == "Bearer xyz123")

		let basic = HTTPHeader.authorization(.basic(username: "user", password: "pass"))
		#expect(basic.name == "Authorization")
		#expect(basic.value.hasPrefix("Basic "))

		let userAgent = HTTPHeader.userAgent("MyApp/1.0")
		#expect(userAgent.name == "User-Agent")
		#expect(userAgent.value == "MyApp/1.0")
	}

	@Test(.tags(.regression)) func testHeaderDescription() {
		let header = HTTPHeader(name: "X-App-Version", value: "2.1.0")
		#expect(header.description == "X-App-Version: 2.1.0")
	}

	@Test(.tags(.regression)) func testHeadersCaseInsensitivityAndMerging() {
		var headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"X-Client-ID": "123",
		]

		#expect(headers["content-type"] == "application/json")
		#expect(headers["x-client-id"] == "123")

		headers["CONTENT-TYPE"] = "text/plain"
		#expect(headers["Content-Type"] == "text/plain")

		let additional: HTTPHeaders = [
			"x-client-id": "456",
			"Authorization": "Bearer token",
		]

		let merged = headers.merging(additional)
		#expect(merged["X-Client-ID"] == "456")
		#expect(merged["Authorization"] == "Bearer token")
		#expect(merged["Content-Type"] == "text/plain")
	}

	@Test(.tags(.regression)) func testHeadersMutationsAndCount() {
		var headers = HTTPHeaders()
		#expect(headers.isEmpty)
		#expect(headers.count == 0)

		headers["Header-1"] = "Value-1"
		headers.add(HTTPHeader(name: "Header-2", value: "Value-2"))
		#expect(!headers.isEmpty)
		#expect(headers.count == 2)

		headers.remove(name: "header-1")
		#expect(headers.count == 1)
		#expect(headers["Header-1"] == nil)

		headers["Header-2"] = nil
		#expect(headers.isEmpty)
		#expect(headers.count == 0)
	}

	@Test(.tags(.regression)) func testHeadersSequenceIteration() {
		let headers: HTTPHeaders = [
			HTTPHeader(name: "A", value: "1"),
			HTTPHeader(name: "B", value: "2"),
		]
		let collected = Array(headers)
		#expect(collected.count == 2)
	}
}
