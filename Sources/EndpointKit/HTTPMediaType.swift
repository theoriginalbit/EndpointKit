//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// A representation of an HTTP media type (MIME type) used in headers such as `Accept` and `Content-Type`.
public struct HTTPMediaType: Equatable, Hashable, Sendable {
	/// The raw string representation of the media type (e.g., `"application/json"`).
	public let rawValue: String

	/// Creates a media type with a raw string value.
	///
	/// - Parameter rawValue: The media type string.
	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}
}

extension HTTPMediaType: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
	public init(stringLiteral value: String) { rawValue = value }
}

extension HTTPMediaType: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String { rawValue }
	public var debugDescription: String { rawValue }
}

// MARK: - Common Media Types

extension HTTPMediaType {
	/// Constructs a custom `application/*` media type.
	///
	/// - Parameter kind: The sub-type kind (e.g., `"json"` or `"pdf"`).
	/// - Returns: An ``HTTPMediaType`` formatted as `"application/<kind>"`.
	public static func application(_ kind: String) -> HTTPMediaType {
		"application/\(kind)"
	}

	/// Constructs a custom `text/*` media type.
	///
	/// - Parameter kind: The sub-type kind (e.g., `"plain"` or `"html"`).
	/// - Returns: An ``HTTPMediaType`` formatted as `"text/<kind>"`.
	public static func text(_ kind: String) -> HTTPMediaType {
		"text/\(kind)"
	}

	/// Media type for JSON data (`application/json`).
	public static let json: HTTPMediaType = .application("json")

	/// Media type for XML data (`application/xml`).
	public static let xml: HTTPMediaType = .application("xml")

	/// Media type for HTML documents (`text/html`).
	public static let html: HTTPMediaType = .text("html")

	/// Media type for plain text content (`text/plain`).
	public static let plainText: HTTPMediaType = .text("plain")

	/// Media type for URL-encoded form data (`application/x-www-form-urlencoded`).
	public static let formURLEncoded: HTTPMediaType = .application("x-www-form-urlencoded")

	/// Media type for multipart form data (`multipart/form-data`).
	public static let multipartFormData: HTTPMediaType = "multipart/form-data"

	/// Media type for arbitrary binary data streams (`application/octet-stream`).
	public static let octetStream: HTTPMediaType = .application("octet-stream")
}
