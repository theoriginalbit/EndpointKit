//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

@testable import EndpointKit

final class MockPerformer: HTTPRequestPerformer, @unchecked Sendable {
	let handler: ((URLRequest) async throws -> (Data, URLResponse))

	init(handler: @escaping (URLRequest) async throws -> (Data, URLResponse)) {
		self.handler = handler
	}

	func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
		return try await handler(request)
	}
}
