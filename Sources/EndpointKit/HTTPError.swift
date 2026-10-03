//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// A protocol defining the standard set of errors thrown during request creation, network execution, or response decoding.
///
/// Types conforming to `HTTPError` represent failures at various stages of the HTTP request lifecycle.
public protocol HTTPError: Error, Sendable {
	/// Creates an error indicating that a valid `URL` could not be constructed from the given `URLComponents`.
	///
	/// - Parameter components: The invalid URL components.
	static func cannotConstructURL(_ components: URLComponents) -> Self

	/// Creates an error indicating a failure during request payload encoding.
	///
	/// - Parameter error: The underlying `EncodingError`.
	static func encodingError(_ error: EncodingError) -> Self

	/// Creates an error indicating an underlying network transport failure.
	///
	/// - Parameter error: The underlying `URLError`.
	static func transportError(_ error: URLError) -> Self

	/// An error indicating that the server response could not be converted to `HTTPURLResponse`.
	static var cannotConvertURLTypes: Self { get }

	/// Creates an error indicating a failure during response decoding.
	///
	/// - Parameter error: The underlying `DecodingError`.
	static func decodingError(_ error: DecodingError) -> Self

	/// Creates an error indicating that the server responded with an HTTP status code outside the successful range.
	///
	/// - Parameters:
	///   - statusCode: The HTTP status code returned by the server.
	///   - data: The raw response body data.
	///   - response: The full `HTTPURLResponse`.
	static func statusError(statusCode: Int, data: Data, response: HTTPURLResponse) -> Self

	/// Creates an error indicating the library was unable to handle the error that occurred.
	///
	/// - Parameter error: The underlying unhandled error.
	static func unhandledError(_ error: any Error) -> Self
}

extension HTTPError {
	/// Helper constructor creating a status error from an `HTTPURLResponse` and response data.
	///
	/// - Parameters:
	///   - response: The HTTP URL response.
	///   - data: The raw response data.
	/// - Returns: An error instance configured with the response's status code.
	@inlinable @inline(__always) public static func statusError(of response: HTTPURLResponse, data: Data) -> Self {
		Self.statusError(statusCode: response.statusCode, data: data, response: response)
	}
}
