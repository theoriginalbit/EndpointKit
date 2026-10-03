//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Protocol for providing authentication state and handling HTTP `401 Unauthorized` and `403 Forbidden` responses.
///
/// Implementations of this protocol provide authorization header values and specify how to handle authentication errors,
/// including automatic token refresh and retry limits.
public protocol HTTPAuthenticationProviding: Sendable {
	/// Provides the current authorization header value for a network request.
	///
	/// - Returns: An ``HTTPAuthenticationHeaderValue`` containing the request's authorization credentials.
	var authenticationHeaderValue: HTTPAuthenticationHeaderValue { get async throws }

	/// The maximum number of retry attempts allowed after receiving a `401 Unauthorized` status response.
	///
	/// Defaults to `1`.
	var maxRetryCount: Int { get }

	/// Invoked when a network request receives a `401 Unauthorized` response status.
	///
	/// Use this method to refresh the credentials.
	///
	/// - Important: This function may be invoked more than once in quick succession if there were multiple in-flight
	/// 			 network calls. You should always check if the current token is valid or has been recently refreshed
	/// 			 and if so return the current value to retry the request with that authentication value.
	///
	/// If your instance is an actor then ensure storage is updated before returning from this function
	/// so any queued calls to `authenticationHeaderValue`, or this function, can receive the new
	/// value immediately.
	///
	/// - Returns: A new ``HTTPAuthenticationHeaderValue`` to retry the request with, or `nil` if authentication cannot be refreshed.
	/// - Throws: An error if token refresh fails.
	func responseWasUnauthorized() async throws -> HTTPAuthenticationHeaderValue?

	/// Invoked when a network request receives a `403 Forbidden` response status.
	///
	/// - Throws: An error if forbidden handling fails.
	func responseWasForbidden() async throws

	/// Invoked when retry attempts after repeated `401 Unauthorized` responses reach ``maxRetryCount``.
	///
	/// - Throws: An error when handling maximum retries limit reaching.
	func exceededMaximumNumberOfRetries() async throws
}

extension HTTPAuthenticationProviding {
	/// Default implementation returning `1` maximum retry attempt.
	public var maxRetryCount: Int { 1 }

	/// Default no-op implementation for handling `403 Forbidden` responses.
	public func responseWasForbidden() async throws {}

	/// Default no-op implementation for handling maximum retry count exceedance.
	public func exceededMaximumNumberOfRetries() async throws {}
}
