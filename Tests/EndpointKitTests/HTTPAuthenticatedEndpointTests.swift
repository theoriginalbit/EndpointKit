//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("HTTPAuthenticatedEndpoint Tests")
struct HTTPAuthenticatedEndpointTests {
	@Test(.tags(.regression)) func testAuthenticatedEndpointPropertyForwarding() async throws {
		let mockAuth = MockAuthenticationProvider(token: "token123")
		let queryItems = [URLQueryItem(name: "filter", value: "active")]
		let headers: HTTPHeaders = ["X-Custom-Header": "CustomValue"]

		let underlyingEndpoint = JSONEndpoint<String, String, EndpointKitError>(
			method: .post,
			path: "items",
			queryItems: queryItems,
			headers: headers,
			body: "Hello World",
			timeoutInterval: 30
		)

		let authenticatedEndpoint = underlyingEndpoint.authenticated(with: mockAuth)

		#expect(authenticatedEndpoint.method == .post)
		#expect(authenticatedEndpoint.path == "items")
		#expect(authenticatedEndpoint.queryItems == queryItems)
		#expect(authenticatedEndpoint.headers["X-Custom-Header"] == "CustomValue")
		#expect(authenticatedEndpoint.timeoutInterval == 30)

		let bodyData = try await authenticatedEndpoint.httpBody
		#expect(bodyData != nil)

		let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		let decoded = try authenticatedEndpoint.decode(bodyData!, response: httpResponse)
		#expect(decoded == "Hello World")
	}
}
