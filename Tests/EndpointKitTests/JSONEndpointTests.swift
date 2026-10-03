//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("JSONEndpoint Tests")
struct JSONEndpointTests {
	@Test(.tags(.regression)) func testEndpointEncodingAndDecoding() async throws {
		let payload = TestPayload(id: "abc", count: 42)
		let endpoint = JSONEndpoint<TestPayload, TestPayload, EndpointKitError>(
			method: .post,
			path: "test",
			body: payload
		)

		let encodedData = try #require(try endpoint.httpBody)
		let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: encodedData)
		#expect(decodedPayload == payload)

		let httpResponse = HTTPURLResponse(
			url: URL(string: "https://api.example.com/v1/test")!,
			statusCode: 200,
			httpVersion: nil,
			headerFields: nil
		)!

		let decodedFromEndpoint = try endpoint.decode(encodedData, response: httpResponse)
		#expect(decodedFromEndpoint == payload)
	}

	@Test(.tags(.regression)) func testDefaultHeadersAndNilBody() async throws {
		let endpoint = JSONEndpoint<EmptyBody, TestPayload, EndpointKitError>(
			method: .get,
			path: "items"
		)

		#expect(endpoint.headers["Accept"] == "application/json")
		#expect(endpoint.headers["Content-Type"] == "application/json")
		#expect(try endpoint.httpBody == nil)
	}

	@Test(.tags(.regression)) func testEmptyResponseDecoding() throws {
		let endpoint = JSONEndpoint<EmptyBody, EmptyResponse, EndpointKitError>(
			method: .delete,
			path: "items/1"
		)

		let httpResponse = HTTPURLResponse(
			url: URL(string: "https://api.example.com/v1/items/1")!,
			statusCode: 204,
			httpVersion: nil,
			headerFields: nil
		)!

		_ = try endpoint.decode(Data(), response: httpResponse)
	}
}

private struct TestPayload: Codable, Equatable, Sendable {
	let id: String
	let count: Int
}
