//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Represents a URI scheme used in HTTP and web network requests.
public struct HTTPScheme: Equatable, Hashable, Sendable {
	/// The raw string representation of the scheme (e.g., `"https"`).
	public let rawValue: String

	/// Initializes a scheme with a string value.
	///
	/// - Parameter value: The scheme string.
	public init(_ value: String) {
		self.rawValue = value
	}
}

extension HTTPScheme: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String { rawValue }
	public var debugDescription: String { rawValue }
}

extension HTTPScheme: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) { self.init(value) }
}

// MARK: - Common Schemes

extension HTTPScheme {
	/// The secure Hypertext Transfer Protocol scheme (`"https"`).
	public static let https: HTTPScheme = "https"

	/// The Hypertext Transfer Protocol scheme (`"http"`).
	public static let http: HTTPScheme = "http"

	/// The secure WebSocket scheme (`"wss"`).
	public static let wss: HTTPScheme = "wss"

	/// The WebSocket scheme (`"ws"`).
	public static let ws: HTTPScheme = "ws"
}
