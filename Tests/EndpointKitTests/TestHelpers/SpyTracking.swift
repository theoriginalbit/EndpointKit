//
// Copyright © 2026 EndpointKit. All rights reserved.
//

actor SpyTracking {
	var called: Bool {
		callCount > 0
	}

	private(set) var callCount: Int = 0

	init() {}

	func track() {
		callCount += 1
	}

	func reset() {
		callCount = 0
	}
}
