//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

/// Note: this entire suite uses ``MockPerformer`` to validate all the wiring declared on ``HTTPRequestPerformer``.
@Suite("HTTPRequestPerformer Tests")
struct HTTPRequestPerformerTests {
	private let client = HTTPClient(host: "api.example.com", basePath: "v1")

	@Test(.tags(.regression)) func testSuccessfulRequestExecution() async throws {
		let expectedResponse = DummyResponse(message: "Success")
		let responseData = try JSONEncoder().encode(expectedResponse)
		let performer = MockPerformer { request in
			#expect(request.url?.absoluteString == "https://api.example.com/v1/user?query=test")
			#expect(request.httpMethod == "GET")
			let response = HTTPURLResponse(
				url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			return (responseData, response)
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "user",
			queryItems: [URLQueryItem(name: "query", value: "test")]
		)

		let result = try await performer.send(endpoint, to: client)
		#expect(result == expectedResponse)
	}

	@Test(.tags(.regression)) func test401UnauthorizedRetrySuccess() async throws {
		let authProvider = MockAuthenticationProvider(token: "initialToken")
		let expectedResponse = DummyResponse(message: "Auth Success")
		let responseData = try JSONEncoder().encode(expectedResponse)
		var requestCount = 0

		let performer = MockPerformer { request in
			requestCount += 1
			if requestCount == 1 {
				#expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer initialToken")
				let response = HTTPURLResponse(
					url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
				return (Data(), response)
			} else {
				#expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer newToken")
				let response = HTTPURLResponse(
					url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
				return (responseData, response)
			}
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "protected"
		).authenticated(with: authProvider)

		let result = try await performer.send(endpoint, to: client)
		#expect(result == expectedResponse)
		#expect(requestCount == 2)
		let unauthorizedCalls = await authProvider.responseWasUnauthorizedSpy.callCount
		#expect(unauthorizedCalls == 1)
	}

	@Test(.tags(.regression)) func test401UnauthorizedRetryExceeded() async throws {
		let authProvider = MockAuthenticationProvider(token: "invalidToken")
		let performer = MockPerformer { request in
			let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
			return (Data(), response)
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "protected"
		).authenticated(with: authProvider)

		do {
			_ = try await performer.send(endpoint, to: client)
			Issue.record("Expected statusError after retry limit exceeded")
		} catch {
			if case .statusError(let statusCode, _, _) = error {
				#expect(statusCode == 401)
			} else {
				Issue.record("Unexpected error type: \(error)")
			}
		}

		let exceededCalls = await authProvider.exceededMaximumNumberOfRetriesSpy.callCount
		#expect(exceededCalls == 1)
	}

	@Test(.tags(.regression)) func test403ForbiddenHandling() async throws {
		let authProvider = MockAuthenticationProvider(token: "someToken")
		let performer = MockPerformer { request in
			let response = HTTPURLResponse(url: request.url!, statusCode: 403, httpVersion: nil, headerFields: nil)!
			return (Data(), response)
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "forbidden"
		).authenticated(with: authProvider)

		do {
			_ = try await performer.send(endpoint, to: client)
			Issue.record("Expected statusError for 403 forbidden")
		} catch {
			if case .statusError(let statusCode, _, _) = error {
				#expect(statusCode == 403)
			} else {
				Issue.record("Unexpected error type: \(error)")
			}
		}

		let forbiddenCalls = await authProvider.responseWasForbiddenSpy.callCount
		#expect(forbiddenCalls == 1)
	}

	@Test(.tags(.regression)) func testTypedThrowsStatusError() async throws {
		let performer = MockPerformer { request in
			let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
			return (Data(), response)
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "notfound"
		)

		do {
			_ = try await performer.send(endpoint, to: client)
			Issue.record("Expected error to be thrown")
		} catch {
			let typedError: EndpointKitError = error
			if case .statusError(let statusCode, _, _) = typedError {
				#expect(statusCode == 404)
			} else {
				Issue.record("Unexpected error: \(typedError)")
			}
		}
	}

	@Test(.tags(.regression)) func testTransportURLErrorHandling() async throws {
		let performer = MockPerformer { _ in
			throw URLError(.notConnectedToInternet)
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .get,
			path: "test"
		)

		do {
			_ = try await performer.send(endpoint, to: client)
			Issue.record("Expected transport error")
		} catch {
			if case .transportError(let urlError) = error {
				#expect(urlError.code == .notConnectedToInternet)
			} else {
				Issue.record("Unexpected error type: \(error)")
			}
		}
	}

	@Test(.tags(.regression)) func testURLRequestBuilderConfiguration() async throws {
		let customClient = HTTPClient(
			scheme: .http,
			host: "localhost",
			port: 8080,
			basePath: "api/v1",
			headers: ["Client-Header": "ClientVal"],
			timeoutInterval: 60
		)

		let performer = MockPerformer { _ in
			fatalError("Should not be called directly in buildURLRequest")
		}

		let endpoint = JSONEndpoint<EmptyBody, DummyResponse, EndpointKitError>(
			method: .post,
			path: "custom",
			headers: ["Endpoint-Header": "EndpointVal"],
			timeoutInterval: 15
		)

		let request = try await performer.buildURLRequest(for: endpoint, on: customClient)

		#expect(request.url?.absoluteString == "http://localhost:8080/api/v1/custom")
		#expect(request.httpMethod == "POST")
		#expect(request.value(forHTTPHeaderField: "Client-Header") == "ClientVal")
		#expect(request.value(forHTTPHeaderField: "Endpoint-Header") == "EndpointVal")
		#expect(request.timeoutInterval == 15)
	}
}

private struct DummyResponse: Codable, Equatable, Sendable {
	let message: String
}
