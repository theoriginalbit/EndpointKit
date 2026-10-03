//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Represents an HTTP response status code.
public struct HTTPStatusCode: Sendable, Equatable, Hashable {
	/// The raw integer HTTP status code (e.g., `200`).
	public let rawValue: Int

	/// Creates an HTTP status code with a raw integer value.
	///
	/// - Parameter rawValue: The status code number.
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	/// Creates an HTTP status code if the value is within valid HTTP range (100...599).
	///
	/// - Parameter value: The status code integer.
	public init?(checkedValue value: Int) {
		guard (100...599).contains(value) else { return nil }
		self.rawValue = value
	}

	/// Indicates whether the status code is in the Informational range (100–199).
	///
	/// - SeeAlso: [MDN Web Docs: Information responses](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#information_responses)
	public var isInformational: Bool { (100...199).contains(rawValue) }

	/// Indicates whether the status code is in the Successful range (200–299).
	///
	/// - SeeAlso: [MDN Web Docs: Successful responses](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#successful_responses)
	public var isSuccess: Bool { (200...299).contains(rawValue) }

	/// Indicates whether the status code is in the Redirection range (300–399).
	///
	/// - SeeAlso: [MDN Web Docs: Redirection messages](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#redirection_messages)
	public var isRedirection: Bool { (300...399).contains(rawValue) }

	/// Indicates whether the status code is in the Client Error range (400–499).
	///
	/// - SeeAlso: [MDN Web Docs: Client error responses](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#client_error_responses)
	public var isClientError: Bool { (400...499).contains(rawValue) }

	/// Indicates whether the status code is in the Server Error range (500–599).
	///
	/// - SeeAlso: [MDN Web Docs: Server error responses](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#server_error_responses)
	public var isServerError: Bool { (500...599).contains(rawValue) }
}

extension HTTPStatusCode: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String { "\(rawValue)" }
	public var debugDescription: String { "\(rawValue)" }
}

// MARK: - Common RESTful Status Codes

extension HTTPStatusCode {
	/// `200 OK`
	public static let ok = HTTPStatusCode(rawValue: 200)

	/// `201 Created`
	public static let created = HTTPStatusCode(rawValue: 201)

	/// `202 Accepted`
	public static let accepted = HTTPStatusCode(rawValue: 202)

	/// `204 No Content`
	public static let noContent = HTTPStatusCode(rawValue: 204)

	/// `301 Moved Permanently`
	public static let movedPermanently = HTTPStatusCode(rawValue: 301)

	/// `302 Found`
	public static let found = HTTPStatusCode(rawValue: 302)

	/// `304 Not Modified`
	public static let notModified = HTTPStatusCode(rawValue: 304)

	/// `400 Bad Request`
	public static let badRequest = HTTPStatusCode(rawValue: 400)

	/// `401 Unauthorized`
	public static let unauthorized = HTTPStatusCode(rawValue: 401)

	/// `403 Forbidden`
	public static let forbidden = HTTPStatusCode(rawValue: 403)

	/// `404 Not Found`
	public static let notFound = HTTPStatusCode(rawValue: 404)

	/// `405 Method Not Allowed`
	public static let methodNotAllowed = HTTPStatusCode(rawValue: 405)

	/// `409 Conflict`
	public static let conflict = HTTPStatusCode(rawValue: 409)

	/// `422 Unprocessable Entity`
	public static let unprocessableEntity = HTTPStatusCode(rawValue: 422)

	/// `500 Internal Server Error`
	public static let internalServerError = HTTPStatusCode(rawValue: 500)

	/// `502 Bad Gateway`
	public static let badGateway = HTTPStatusCode(rawValue: 502)

	/// `503 Service Unavailable`
	public static let serviceUnavailable = HTTPStatusCode(rawValue: 503)

	/// `504 Gateway Timeout`
	public static let gatewayTimeout = HTTPStatusCode(rawValue: 504)
}
