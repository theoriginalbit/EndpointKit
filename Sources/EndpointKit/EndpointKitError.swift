//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Default error type for EndpointKit network operations.
public enum EndpointKitError: HTTPError, Error {
	/// Indicates that a valid `URL` could not be constructed from the specified URL components.
	case cannotConstructURL(URLComponents)

	/// Indicates an error occurred while encoding a request body payload.
	case encodingError(EncodingError)

	/// Indicates an underlying network transport error occurred during request execution.
	case transportError(URLError)

	/// Indicates the server response could not be converted to `HTTPURLResponse`.
	case cannotConvertURLTypes

	/// Indicates an error occurred while decoding the response payload.
	case decodingError(DecodingError)

	/// Indicates that the server responded with an HTTP status code outside the successful (2xx) range.
	///
	/// - Parameters:
	///   - statusCode: The HTTP status code number.
	///   - data: The raw body data returned by the server.
	///   - response: The full `HTTPURLResponse` received from the server.
	case statusError(statusCode: Int, data: Data, response: HTTPURLResponse)

	/// Indicates an unhandled or unexpected error occurred during request execution.
	case unhandledError(any Error)
}

extension EndpointKitError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .cannotConstructURL(let components):
			return "Cannot construct URL from components: \(components)"
		case .encodingError(let error):
			return "Encoding error: \(error.localizedDescription)"
		case .transportError(let error):
			return "Transport error: \(error.localizedDescription)"
		case .cannotConvertURLTypes:
			return "Response could not be converted to HTTPURLResponse"
		case .decodingError(let error):
			return "Decoding error: \(error.localizedDescription)"
		case .statusError(let statusCode, _, _):
			return "HTTP error status code: \(statusCode)"
		case .unhandledError(let error):
			return "Unhandled error: \(error.localizedDescription)"
		}
	}
}
