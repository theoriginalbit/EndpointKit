//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Wraps an ``HTTPEndpoint`` with an authentication provider, indicating to the request performer that authorization is required.
public struct HTTPAuthenticatedEndpoint<Endpoint: HTTPEndpoint, AuthenticationProvider: HTTPAuthenticationProviding>: HTTPEndpoint {
	/// The response type returned when executing this endpoint.
	public typealias Response = Endpoint.Response

	/// The error type thrown during request execution or response handling.
	public typealias ErrorKind = Endpoint.ErrorKind

	/// The underlying endpoint being executed.
	public let endpoint: Endpoint

	/// The provider responsible for supplying authentication credentials and handling 401 retries and 403 failures.
	public let authenticationProvider: AuthenticationProvider

	/// Creates a new authenticated endpoint wrapping an underlying endpoint and an authentication provider.
	///
	/// - Parameters:
	///   - endpoint: The endpoint to execute with authentication.
	///   - authenticationProvider: The authentication provider for header generation and retry handling.
	public init(endpoint: Endpoint, authenticationProvider: AuthenticationProvider) {
		self.endpoint = endpoint
		self.authenticationProvider = authenticationProvider
	}

	/// The HTTP method of the wrapped endpoint.
	public var method: HTTPMethod { endpoint.method }

	/// An optional relative path segment of the wrapped endpoint.
	public var path: String? { endpoint.path }

	/// Optional query items of the wrapped endpoint.
	public var queryItems: [URLQueryItem]? { endpoint.queryItems }

	/// HTTP headers specific to the wrapped endpoint.
	public var headers: HTTPHeaders { endpoint.headers }

	/// The HTTP body payload of the wrapped endpoint.
	public var httpBody: Data? {
		get async throws {
			try await endpoint.httpBody
		}
	}

	/// Optional request timeout interval of the wrapped endpoint.
	public var timeoutInterval: TimeInterval? { endpoint.timeoutInterval }

	/// Decodes the server response data into the expected `Response` type using the wrapped endpoint's decoder.
	///
	/// - Parameters:
	///   - data: The raw response data.
	///   - response: The HTTP URL response.
	/// - Returns: The decoded response object.
	/// - Throws: An error if response decoding fails.
	public func decode(_ data: Data, response: HTTPURLResponse) throws -> Endpoint.Response {
		try endpoint.decode(data, response: response)
	}
}

// MARK: - Convenience

extension HTTPEndpoint {
	/// Wraps this endpoint with an authentication provider, producing an ``HTTPAuthenticatedEndpoint``.
	///
	/// - Parameter provider: The authentication provider supplying credentials and retry handling.
	/// - Returns: An authenticated endpoint instance wrapping `self`.
	public func authenticated<Auth: HTTPAuthenticationProviding>(with provider: Auth) -> HTTPAuthenticatedEndpoint<Self, Auth> {
		HTTPAuthenticatedEndpoint(endpoint: self, authenticationProvider: provider)
	}
}
