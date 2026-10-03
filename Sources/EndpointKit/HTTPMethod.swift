//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Represents an HTTP request method, conforming to `ExpressibleByStringLiteral` for flexible custom methods.
public struct HTTPMethod: Equatable, Hashable, Sendable {
	/// The raw uppercase string representation of the HTTP method (e.g., `"GET"`).
	public let rawValue: String

	/// Initializes an HTTP method with a string value.
	///
	/// - Parameter value: The method string.
	public init(_ value: String) {
		self.rawValue = value
	}
}

extension HTTPMethod: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String { rawValue }
	public var debugDescription: String { rawValue }
}

extension HTTPMethod: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) { self.rawValue = value }
}

// MARK: - Common HTTP Methods

extension HTTPMethod {
	/// The HTTP `GET` method requests a representation of the specified resource.
	public static let get: HTTPMethod = "GET"

	/// The HTTP `POST` method submits an entity to the specified resource, often causing a change in state or side effects.
	public static let post: HTTPMethod = "POST"

	/// The HTTP `QUERY` method performs safe, idempotent, parameter-based querying with a request body.
	public static let query: HTTPMethod = "QUERY"

	/// The HTTP `PUT` method replaces all current representations of the target resource with the request payload.
	public static let put: HTTPMethod = "PUT"

	/// The HTTP `PATCH` method applies partial modifications to a resource.
	public static let patch: HTTPMethod = "PATCH"

	/// The HTTP `DELETE` method deletes the specified resource.
	public static let delete: HTTPMethod = "DELETE"

	/// The HTTP `HEAD` method asks for a response identical to a `GET` request, but without the response body.
	public static let head: HTTPMethod = "HEAD"

	/// The HTTP `OPTIONS` method describes the communication options for the target resource.
	public static let options: HTTPMethod = "OPTIONS"

	/// The HTTP `TRACE` method performs a message loop-back test along the path to the target resource.
	public static let trace: HTTPMethod = "TRACE"

	/// The HTTP `CONNECT` method establishes a tunnel to the server identified by the target resource.
	public static let connect: HTTPMethod = "CONNECT"
}
