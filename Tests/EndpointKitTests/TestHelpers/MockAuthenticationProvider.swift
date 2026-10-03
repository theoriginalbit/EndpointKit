//
// Copyright © 2026 EndpointKit. All rights reserved.
//

@testable import EndpointKit

actor MockAuthenticationProvider: HTTPAuthenticationProviding {
	var token: String

	init(token: String) {
		self.token = token
	}

	let authenticationHeaderValueSpy = SpyTracking()
	var authenticationHeaderValue: HTTPAuthenticationHeaderValue {
		get async throws {
			await authenticationHeaderValueSpy.track()
			return .bearer(token)
		}
	}

	let responseWasUnauthorizedSpy = SpyTracking()
	func responseWasUnauthorized() async throws -> HTTPAuthenticationHeaderValue? {
		await responseWasUnauthorizedSpy.track()
		token = "newToken"
		return .bearer(token)
	}

	let responseWasForbiddenSpy = SpyTracking()
	func responseWasForbidden() async throws {
		await responseWasForbiddenSpy.track()
	}

	let exceededMaximumNumberOfRetriesSpy = SpyTracking()
	func exceededMaximumNumberOfRetries() async throws {
		await exceededMaximumNumberOfRetriesSpy.track()
	}
}
