//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// A generic endpoint implementation for JSON APIs supporting typed request encoding and response decoding.
///
/// `JSONEndpoint` simplifies defining endpoints that communicate using JSON payloads. It automatically
/// attaches `Accept: application/json` and `Content-Type: application/json` headers, and can use
/// customizable `JSONEncoder` and `JSONDecoder` instances for serialization.
public struct JSONEndpoint<Request: Encodable & Sendable, Response: Decodable & Sendable, ErrorKind: HTTPError>: HTTPEndpoint<Response, ErrorKind> {
	/// The HTTP method for the request (e.g., `.get`, `.post`).
	public let method: HTTPMethod

	/// An optional path segment relative to the client's base path.
	public let path: String?

	/// Optional query parameters appended to the request URL.
	public let queryItems: [URLQueryItem]?

	/// HTTP headers specific to this endpoint.
	public let headers: HTTPHeaders

	/// The request body payload model to encode as JSON.
	public let body: Request?

	/// Optional custom request timeout interval in seconds.
	public let timeoutInterval: TimeInterval?

	/// The encoder used to serialize the `body` into JSON `Data`.
	public let encoder: JSONEncoder

	/// The decoder used to parse the server response `Data` into `Response`.
	public let decoder: JSONDecoder

	/// Creates a new JSON API endpoint definition.
	///
	/// - Parameters:
	///   - method: The HTTP method for the request.
	///   - path: An optional path relative to the client's base path.
	///   - queryItems: Optional URL query parameters.
	///   - headers: Custom headers for this endpoint. Defaults to empty (overriding default JSON headers if specified).
	///   - body: An optional request body payload of type `Request`.
	///   - timeoutInterval: An optional request timeout interval in seconds.
	///   - encoder: A `JSONEncoder` instance used for body encoding. Defaults to a standard `JSONEncoder()`.
	///   - decoder: A `JSONDecoder` instance used for response decoding. Defaults to a standard `JSONDecoder()`.
	public init(
		method: HTTPMethod,
		path: String?,
		queryItems: [URLQueryItem]? = nil,
		headers: HTTPHeaders = [:],
		body: Request? = nil,
		timeoutInterval: TimeInterval? = nil,
		encoder: JSONEncoder = JSONEncoder(),
		decoder: JSONDecoder = JSONDecoder()
	) {
		self.method = method
		self.path = path
		self.queryItems = queryItems

		let defaultHeaders: HTTPHeaders = [
			.accept(.json),
			.contentType(.json),
		]
		self.headers = defaultHeaders.merging(headers)

		self.body = body
		self.timeoutInterval = timeoutInterval
		self.encoder = encoder
		self.decoder = decoder
	}

	/// Encodes the `body` property into JSON data using `encoder`.
	///
	/// - Returns: JSON encoded `Data` if `body` is non-nil, or `nil` otherwise.
	/// - Throws: An `EncodingError` if serialization fails.
	public var httpBody: Data? {
		get throws {
			if let body {
				return try encoder.encode(body)
			}
			return nil
		}
	}

	/// Decodes response data into the expected `Response` type using `decoder`.
	///
	/// - Parameters:
	///   - data: Raw body data returned by the server.
	///   - response: The HTTP URL response.
	/// - Returns: A decoded `Response` object.
	/// - Throws: A `DecodingError` if deserialization fails.
	public func decode(_ data: Data, response: HTTPURLResponse) throws -> Response {
		return try decoder.decode(Response.self, from: data)
	}
}

extension JSONEndpoint where Response == EmptyResponse {
	/// Decodes responses for endpoints with `EmptyResponse` without parsing JSON data.
	///
	/// - Parameters:
	///   - data: Raw response data (unused).
	///   - response: The HTTP URL response (unused).
	/// - Returns: An ``EmptyResponse`` instance.
	public func decode(_ data: Data, response: HTTPURLResponse) throws -> Response {
		EmptyResponse()
	}
}
