//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// A representation of a single HTTP header field name and value pair.
public struct HTTPHeader: Equatable, Hashable, Sendable {
	/// Type alias for ``HTTPMediaType``.
	public typealias MediaType = HTTPMediaType

	/// The name of the HTTP header field (e.g., `"Content-Type"`).
	public let name: String

	/// The value of the HTTP header field (e.g., `"application/json"`).
	public let value: String

	/// Initializes a new HTTP header with a name and value.
	/// - Parameters:
	///   - name: The field name of the HTTP header.
	///   - value: The field value of the HTTP header.
	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}
}

extension HTTPHeader: CustomStringConvertible {
	public var description: String { "\(name): \(value)" }
}

// MARK: - Common Header Builders

extension HTTPHeader {
	/// Returns an `Accept` header with the specified media type.
	///
	/// - Parameter mediaType: The media type to accept.
	/// - Returns: An ``HTTPHeader`` for the `Accept` field.
	/// - SeeAlso: [MDN Web Docs: Accept](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept)
	public static func accept(_ mediaType: MediaType) -> HTTPHeader {
		HTTPHeader(name: "Accept", value: mediaType.rawValue)
	}

	/// Returns a `Content-Type` header with the specified media type.
	///
	/// - Parameter mediaType: The media type of the request entity body.
	/// - Returns: An ``HTTPHeader`` for the `Content-Type` field.
	/// - SeeAlso: [MDN Web Docs: Content-Type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
	public static func contentType(_ mediaType: MediaType) -> HTTPHeader {
		HTTPHeader(name: "Content-Type", value: mediaType.rawValue)
	}

	/// Returns an `Authorization` header with the specified authentication header value.
	///
	/// - Parameter value: The authentication header credentials.
	/// - Returns: An ``HTTPHeader`` for the `Authorization` field.
	/// - SeeAlso: [MDN Web Docs: Authorization](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization)
	public static func authorization(_ value: HTTPAuthenticationHeaderValue) -> HTTPHeader {
		HTTPHeader(name: "Authorization", value: value.value)
	}

	/// Returns a `User-Agent` header with the specified value.
	///
	/// - Parameter value: The user agent string identifying the client.
	/// - Returns: An ``HTTPHeader`` for the `User-Agent` field.
	/// - SeeAlso: [MDN Web Docs: User-Agent](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent)
	public static func userAgent(_ value: String) -> HTTPHeader {
		HTTPHeader(name: "User-Agent", value: value)
	}
}
