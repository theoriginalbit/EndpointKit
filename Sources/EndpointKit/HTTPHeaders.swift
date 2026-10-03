//
// Copyright © 2026 EndpointKit. All rights reserved.
//

import Foundation

/// A structured collection of HTTP headers with case-insensitive field name handling and deduplication.
public struct HTTPHeaders: Sequence, Equatable, Sendable {
	private var storage: [String: HTTPHeader] = [:]

	/// A Boolean value indicating whether the header collection is empty.
	public var isEmpty: Bool {
		storage.isEmpty
	}

	/// The number of unique headers in the collection.
	public var count: Int {
		storage.count
	}

	/// Creates a new collection of headers from an array of ``HTTPHeader`` items.
	///
	/// - Parameter headers: An array of headers to populate the collection with.
	public init(_ headers: [HTTPHeader] = []) {
		for header in headers {
			add(header)
		}
	}

	/// Creates a new collection of headers from a string dictionary.
	///
	/// - Parameter dictionary: A dictionary mapping header names to header values.
	public init(_ dictionary: [String: String]) {
		for (name, value) in dictionary {
			add(HTTPHeader(name: name, value: value))
		}
	}

	/// Adds or updates a header in the collection.
	///
	/// - Parameter header: The header to add. Existing headers with matching case-insensitive names are replaced.
	public mutating func add(_ header: HTTPHeader) {
		let key = header.name.lowercased()
		storage[key] = header
	}

	/// Removes a header from the collection by case-insensitive name.
	///
	/// - Parameter name: The name of the header field to remove.
	public mutating func remove(name: String) {
		storage.removeValue(forKey: name.lowercased())
	}

	/// Accesses or updates the value of a header by case-insensitive name.
	///
	/// - Parameter name: The header field name to look up or replace.
	public subscript(name: String) -> String? {
		get {
			storage[name.lowercased()]?.value
		}
		set {
			if let newValue {
				add(HTTPHeader(name: name, value: newValue))
			} else {
				remove(name: name)
			}
		}
	}

	/// Merges these headers with another set of headers.
	///
	/// Headers from `other` override any existing headers with matching case-insensitive field names.
	///
	/// - Parameter other: The collection of headers to merge with this instance.
	/// - Returns: A new ``HTTPHeaders`` instance containing the merged header set.
	public func merging(_ other: HTTPHeaders) -> HTTPHeaders {
		var merged = self
		for header in other {
			merged.add(header)
		}
		return merged
	}

	// MARK: Sequence Conformance

	/// Returns an iterator over the headers in the collection.
	/// - Returns: An iterator yielding ``HTTPHeader`` elements.
	public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
		Array(storage.values).makeIterator()
	}
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: HTTPHeader...) {
		self.init(elements)
	}
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (String, String)...) {
		for (name, value) in elements {
			add(HTTPHeader(name: name, value: value))
		}
	}
}
