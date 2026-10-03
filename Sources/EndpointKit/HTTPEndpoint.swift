//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Represents an empty HTTP request body payload for endpoints that do not transmit data.
public struct EmptyBody: Encodable, Sendable {
	public init() {}
}

/// Represents an empty HTTP response type for endpoints that return no content.
public struct EmptyResponse: Decodable, Sendable {
	public init() {}
}

/// Protocol defining a network request endpoint and its expected response type.
///
/// Types conforming to `HTTPEndpoint` describe an HTTP request (method, path, headers, body, parameters)
/// and how to transform the raw response `Data` into a strongly-typed `Response`.
public protocol HTTPEndpoint<Response, ErrorKind>: Sendable {
	/// The expected response model type decoded from the HTTP response body.
	associatedtype Response: Sendable

	/// The type of error thrown during request building or response processing. Defaults to ``EndpointKitError``.
	associatedtype ErrorKind: HTTPError = EndpointKitError

	/// The HTTP method for the request (e.g., `.get`, `.post`).
	var method: HTTPMethod { get }

	/// An optional path segment relative to the client's base URL.
	var path: String? { get }

	/// Optional query parameters appended to the request URL.
	var queryItems: [URLQueryItem]? { get }

	/// Additional HTTP headers specific to this endpoint.
	var headers: HTTPHeaders { get }

	/// The HTTP request body payload data, if any.
	var httpBody: Data? { get async throws }

	/// Optional custom timeout interval for this specific endpoint in seconds.
	var timeoutInterval: TimeInterval? { get }

	/// Decodes the server response data into the expected `Response` type.
	///
	/// - Parameters:
	///   - data: The raw body data returned by the server.
	///   - response: The HTTP URL response received from the server.
	/// - Returns: A decoded instance of `Response`.
	/// - Throws: An error if decoding fails.
	func decode(_ data: Data, response: HTTPURLResponse) throws -> Response
}

extension HTTPEndpoint {
	/// Default value for optional query items (`nil`).
	public var queryItems: [URLQueryItem]? { nil }

	/// Default empty headers dictionary (`[:]`).
	public var headers: HTTPHeaders { [:] }

	/// Default empty request body payload (`nil`).
	public var httpBody: Data? { nil }

	/// Default timeout interval (`nil`), falling back to the client's timeout.
	public var timeoutInterval: TimeInterval? { nil }
}
