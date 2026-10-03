//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation
import Testing

@testable import EndpointKit

@Suite("EndpointKitError Tests")
struct EndpointKitErrorTests {
	@Test(.tags(.regression)) func testCustomStringConvertibleDescriptions() {
		let components = URLComponents()
		let urlError = EndpointKitError.cannotConstructURL(components)
		#expect(urlError.description.contains("Cannot construct URL"))

		let encodingError = EncodingError.invalidValue("test", .init(codingPath: [], debugDescription: "Invalid payload"))
		let error1 = EndpointKitError.encodingError(encodingError)
		#expect(error1.description.contains("Encoding error"))

		let transportErr = URLError(.notConnectedToInternet)
		let error2 = EndpointKitError.transportError(transportErr)
		#expect(error2.description.contains("Transport error"))

		let error3 = EndpointKitError.cannotConvertURLTypes
		#expect(error3.description == "Response could not be converted to HTTPURLResponse")

		let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Corrupted"))
		let error4 = EndpointKitError.decodingError(decodingError)
		#expect(error4.description.contains("Decoding error"))

		let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
		let error5 = EndpointKitError.statusError(statusCode: 500, data: Data(), response: httpResponse)
		#expect(error5.description == "HTTP error status code: 500")

		struct CustomError: Error, CustomStringConvertible {
			var description: String { "Custom test error" }
		}
		let error6 = EndpointKitError.unhandledError(CustomError())
		#expect(error6.description.contains("Unhandled error"))
	}

	@Test(.tags(.regression)) func testHTTPErrorStatusErrorHelper() {
		let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 403, httpVersion: nil, headerFields: nil)!
		let data = Data("Forbidden".utf8)
		let error: EndpointKitError = .statusError(of: response, data: data)

		if case .statusError(let statusCode, let errorData, let resp) = error {
			#expect(statusCode == 403)
			#expect(errorData == data)
			#expect(resp == response)
		} else {
			Issue.record("Expected statusError case")
		}
	}
}
