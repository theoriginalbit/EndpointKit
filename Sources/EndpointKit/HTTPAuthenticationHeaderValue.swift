//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Represents an HTTP authorization header value.
public struct HTTPAuthenticationHeaderValue: Equatable, Sendable {
	/// The raw string value of the authorization header (e.g., `"Bearer token123"`).
	public let value: String

	/// Creates a new authentication header value with a raw header string.
	///
	/// - Parameter value: The complete header value string.
	public init(_ value: String) {
		self.value = value
	}

	/// Creates a `Bearer` token authorization header value.
	///
	/// - Parameter token: The raw token string or pre-formatted Bearer token string.
	/// - Returns: An ``HTTPAuthenticationHeaderValue`` formatted with the `Bearer` scheme.
	public static func bearer(_ token: String) -> HTTPAuthenticationHeaderValue {
		if token.hasPrefix("Bearer ") {
			return HTTPAuthenticationHeaderValue(token)
		}
		return HTTPAuthenticationHeaderValue("Bearer \(token)")
	}

	/// Creates a `Basic` credentials authorization header value.
	///
	/// - Parameters:
	///   - username: The authentication username.
	///   - password: The authentication password.
	/// - Returns: An ``HTTPAuthenticationHeaderValue`` containing base64-encoded credentials.
	public static func basic(username: String, password: String) -> HTTPAuthenticationHeaderValue {
		let credentials = "\(username):\(password)"
		let base64 = Data(credentials.utf8).base64EncodedString()
		return HTTPAuthenticationHeaderValue("Basic \(base64)")
	}
}

extension HTTPAuthenticationHeaderValue: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) {
		self.value = value
	}
}
