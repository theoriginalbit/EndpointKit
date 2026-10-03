//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// Protocol for executing network requests for ``HTTPEndpoint`` objects.
///
/// `HTTPRequestPerformer` decouples request execution from concrete implementations like `URLSession`,
/// allowing easy mocking and testability. `URLSession` conforms to `HTTPRequestPerformer` out-of-the-box.
public protocol HTTPRequestPerformer: Sendable {
	/// Executes the underlying data task for a given `URLRequest`.
	///
	/// - Parameters:
	///   - request: The `URLRequest` to execute.
	///   - delegate: An optional URLSession task delegate.
	/// - Returns: A tuple containing the response `Data` and `URLResponse`.
	/// - Throws: An error if the request fails to execute.
	func data(
		for request: URLRequest,
		delegate: (any URLSessionTaskDelegate)?
	) async throws -> (Data, URLResponse)
}

extension HTTPRequestPerformer {
	/// Executes a request for an unauthenticated endpoint.
	///
	/// - Parameter endpoint: The endpoint to construct and execute.
	/// - Returns: The decoded response model.
	/// - Throws: An error conforming to `Endpoint.ErrorKind` if request creation, transport, status checking, or decoding fails.
	@_disfavoredOverload
	public func send<Endpoint: HTTPEndpoint>(
		_ endpoint: Endpoint,
		to client: HTTPClient,
	) async throws(Endpoint.ErrorKind) -> Endpoint.Response {
		let request = try await buildURLRequest(for: endpoint, on: client)
		return try await execute(
			request: request,
			endpoint: endpoint,
			authenticationProvider: nil,
			remainingRetries: 0
		)
	}

	/// Executes a request for an authenticated endpoint with authorization header injection and retry handling.
	///
	/// - Parameter authenticatedEndpoint: The authenticated endpoint wrapping an underlying endpoint and authentication provider.
	/// - Returns: The decoded response model.
	/// - Throws: An error conforming to `Endpoint.ErrorKind` if request creation, authentication, transport, status checking, or decoding fails.
	public func send<Endpoint: HTTPEndpoint, Auth: HTTPAuthenticationProviding>(
		_ authenticatedEndpoint: HTTPAuthenticatedEndpoint<Endpoint, Auth>,
		to client: HTTPClient,
	) async throws(Endpoint.ErrorKind) -> Endpoint.Response {
		let endpoint = authenticatedEndpoint.endpoint
		let authProvider = authenticatedEndpoint.authenticationProvider
		var request = try await buildURLRequest(for: endpoint, on: client)

		let authHeader: HTTPHeader
		do {
			let authHeaderValue = try await authProvider.authenticationHeaderValue
			authHeader = .authorization(authHeaderValue)
		} catch let error as Endpoint.ErrorKind {
			throw error
		} catch {
			throw Endpoint.ErrorKind.unhandledError(error)
		}

		request.setValue(authHeader.value, forHTTPHeaderField: authHeader.name)

		return try await execute(
			request: request,
			endpoint: endpoint,
			authenticationProvider: authProvider,
			remainingRetries: authProvider.maxRetryCount
		)
	}

	internal func buildURLRequest<Endpoint: HTTPEndpoint>(
		for endpoint: Endpoint,
		on client: HTTPClient
	) async throws(Endpoint.ErrorKind) -> URLRequest {
		var components = URLComponents()
		components.scheme = client.scheme.rawValue
		components.host = client.host
		components.port = client.port
		components.queryItems = endpoint.queryItems

		guard var url = components.url else {
			throw Endpoint.ErrorKind.cannotConstructURL(components)
		}

		if let basePath = client.basePath, !basePath.isEmpty {
			url.append(path: basePath)
		}
		if let path = endpoint.path, !path.isEmpty {
			url.append(path: path)
		}

		var request = URLRequest(url: url)
		request.httpMethod = endpoint.method.rawValue

		let mergedHeaders = client.headers.merging(endpoint.headers)
		for (name, value) in Dictionary(uniqueKeysWithValues: mergedHeaders.map { ($0.name, $0.value) }) {
			request.setValue(value, forHTTPHeaderField: name)
		}

		if let timeout = endpoint.timeoutInterval ?? client.timeoutInterval {
			request.timeoutInterval = timeout
		}

		do {
			request.httpBody = try await endpoint.httpBody
		} catch let error as Endpoint.ErrorKind {
			throw error
		} catch let error as EncodingError {
			throw Endpoint.ErrorKind.encodingError(error)
		} catch {
			throw Endpoint.ErrorKind.unhandledError(error)
		}

		return request
	}

	internal func execute<Endpoint: HTTPEndpoint>(
		request: URLRequest,
		endpoint: Endpoint,
		authenticationProvider: (any HTTPAuthenticationProviding)?,
		remainingRetries: Int
	) async throws(Endpoint.ErrorKind) -> Endpoint.Response {
		do {
			let (data, response) = try await self.data(for: request, delegate: nil)

			guard let httpResponse = response as? HTTPURLResponse else {
				throw Endpoint.ErrorKind.cannotConvertURLTypes
			}

			guard let statusCode = HTTPStatusCode(checkedValue: httpResponse.statusCode) else {
				throw Endpoint.ErrorKind.statusError(of: httpResponse, data: data)
			}

			if statusCode.isSuccess {
				return try endpoint.decode(data, response: httpResponse)
			}

			switch statusCode {
			case .unauthorized:
				if remainingRetries > 0, let authProvider = authenticationProvider {
					let headerValue = try await authProvider.responseWasUnauthorized()
					if let headerValue {
						let header = HTTPHeader.authorization(headerValue)
						var retryRequest = request
						retryRequest.setValue(header.value, forHTTPHeaderField: header.name)
						return try await execute(
							request: retryRequest,
							endpoint: endpoint,
							authenticationProvider: authProvider,
							remainingRetries: remainingRetries - 1
						)
					}
				} else if let authProvider = authenticationProvider {
					try await authProvider.exceededMaximumNumberOfRetries()
				}

			case .forbidden:
				try await authenticationProvider?.responseWasForbidden()

			default:
				break
			}

			throw Endpoint.ErrorKind.statusError(of: httpResponse, data: data)
		} catch let error as Endpoint.ErrorKind {
			throw error
		} catch let error as URLError {
			throw .transportError(error)
		} catch let error as DecodingError {
			throw .decodingError(error)
		} catch {
			throw .unhandledError(error)
		}
	}
}

extension URLSession: HTTPRequestPerformer {}
