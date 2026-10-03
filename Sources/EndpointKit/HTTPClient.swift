//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Defines a network service configuration including scheme, host, port, base path, default headers, and request timeout.
///
/// `HTTPClient` serves as the base configuration for API services, holding shared values like domain, URL scheme,
/// base path prefix, and default headers applied across all endpoints targeting that service.
public struct HTTPClient: Equatable, Sendable {
	/// The URL scheme for requests, typically `"https"` or `"http"`.
	public let scheme: HTTPScheme

	/// The target server hostname or IP address (e.g., `"api.example.com"`).
	public let host: String

	/// An optional network port number (e.g., `8080`).
	public let port: Int?

	/// An optional base URL path segment prepended to endpoint paths (e.g., `"v1"` or `"api/v2"`).
	public let basePath: String?

	/// Default HTTP headers attached to all requests for this service client.
	public let headers: HTTPHeaders

	/// An optional request timeout interval in seconds.
	public let timeoutInterval: TimeInterval?

	/// Creates a new service client configuration.
	///
	/// - Parameters:
	///   - scheme: The URL scheme, defaulting to `https`.
	///   - host: The host domain or IP address.
	///   - port: An optional port number.
	///   - basePath: An optional base path segment appended to requests.
	///   - headers: Default headers attached to requests for this service.
	///   - timeoutInterval: An optional request timeout in seconds.
	public init(
		scheme: HTTPScheme = .https,
		host: String,
		port: Int? = nil,
		basePath: String? = nil,
		headers: HTTPHeaders = [:],
		timeoutInterval: TimeInterval? = nil
	) {
		self.scheme = scheme
		self.host = host
		self.port = port
		self.basePath = basePath
		self.headers = headers
		self.timeoutInterval = timeoutInterval
	}
}
