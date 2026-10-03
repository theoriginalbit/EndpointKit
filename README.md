# EndpointKit

A lightweight, type-safe HTTP networking library for Swift. It provides a clean and declarative approach to defining API requests, managing client configurations, executing network requests via `URLSession`, and handling authentication with automatic token refresh.

> [!TIP]
> If you have an OpenAPI definition of your API then I highly recommend you look into using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator), [swift-openapi-runtime](https://github.com/apple/swift-openapi-runtime), and [swift-openapi-urlsession](https://github.com/apple/swift-openapi-urlsession).
> However, this library is a good alternative if you cannot use OpenAPI.

## Features

- **Swift Concurrency Ready**: Built using Swift `async`/`await` and `Sendable` types for safe concurrent operations.
- **Authentication**: Wrap endpoints with `HTTPAuthenticationProviding` to handle auth headers and automatic token refresh on `401 Unauthorized` responses.
- **Native `URLSession` Integration**: Directly execute requests via `URLSession.shared.send(endpoint)` using `HTTPRequestPerformer`.
- **Strongly-Typed HTTP Utilities**: Expressive types for HTTP methods (`HTTPMethod`), status codes (`HTTPStatusCode`), headers (`HTTPHeader`), and media types (`HTTPMediaType`).

## Installation

Add `EndpointKit` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/theoriginalbit/EndpointKit.git", from: "1.0.0")
]
```

Or add it directly in Xcode via **File > Add Package Dependencies...**.

## Quick Start

### 1. Define a Client Configuration

An `HTTPClient` holds common configuration details for a web service, such as host, base path, scheme, default headers, and timeouts:
```swift
import EndpointKit

let apiClient = HTTPClient(
    scheme: .https,
    host: "api.example.com",
    basePath: "v1",
    headers: [
        .userAgent("MyApp/1.0.0")
    ],
    timeoutInterval: 30
)
```

### 2. Create Endpoints

Use `JSONEndpoint` to quickly create strongly typed API endpoints:
```swift
import Foundation
import EndpointKit

struct User: Codable, Sendable {
    let id: String
    let name: String
    let email: String
}

struct CreateUserRequest: Codable, Sendable {
    let name: String
    let email: String
}

// GET /v1/users/{id}
func getUserEndpoint(id: String) -> JSONEndpoint<EmptyBody, User, EndpointKitError> {
    JSONEndpoint(
        method: .get,
        path: "users/\(id)"
    )
}

// POST /v1/users
func createUserEndpoint(request: CreateUserRequest) -> JSONEndpoint<CreateUserRequest, User, EndpointKitError> {
    JSONEndpoint(
        method: .post,
        path: "users",
        body: request
    )
}
```

> [!TIP]
> You can provide your own `JSONEncoder` and `JSONDecoder` to `JSONEndpoint`'s initializer in order to control encoding/decoding settings such as date and data formatters.

### 3. Send Requests

Execute requests directly using `URLSession` (or any custom `HTTPRequestPerformer` implementation):
```swift
do {
    let endpoint = getUserEndpoint(id: "usr_123")
    let user = try await URLSession.shared.send(endpoint, to: apiClient)
    print("Fetched user:", user.name)
} catch let error as EndpointKitError {
    print("Endpoint error:", error)
} catch {
    print("Unexpected error:", error)
}
```

## Custom Endpoints

For non-JSON responses or custom data formatting, conform directly to `HTTPEndpoint`:
```swift
import Foundation
import EndpointKit

struct GetImageEndpoint: HTTPEndpoint<Data, EndpointKitError> {
    let method: HTTPMethod = .get
    let path: String?

    init(imagePath: String) {
        self.path = imagePath
    }

    func decode(_ data: Data, response: HTTPURLResponse) throws -> Data {
        data
    }
}
```

---

## Authenticated Endpoints

Implement `HTTPAuthenticationProviding` to manage auth credentials and handle automatic retries when receiving `401 Unauthorized` responses:

```swift
import EndpointKit

actor AuthManager: HTTPAuthenticationProviding {
    private var accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    var authenticationHeaderValue: HTTPAuthenticationHeaderValue {
        get async throws {
            .bearer(accessToken)
        }
    }

    var maxRetryCount: Int { 1 }

    func responseWasUnauthorized() async throws -> HTTPAuthenticationHeaderValue? {
        // Refresh token asynchronously
        let newToken = try await refreshAccessToken()
        self.accessToken = newToken
        return .bearer(newToken)
    }

    func responseWasForbidden() async throws {
        print("Access denied (403 Forbidden)")
    }

    func exceededMaximumNumberOfRetries() async throws {
        print("Authentication retry limit exceeded")
    }

    private func refreshAccessToken() async throws -> String {
        // Implement token refresh logic which could also talk to the network
        return "new_access_token"
    }
}
```

> [!IMPORTANT]
> Each function of `HTTPAuthenticationProviding` supports async and throwing allowing you full control of how you store your secrets.

Wrap any endpoint using `.authenticated(with:)`:
```swift
let authManager = AuthManager(accessToken: "current_token")

let protectedEndpoint = getUserEndpoint(id: "usr_123")
    .authenticated(with: authManager)

let user = try await URLSession.shared.send(protectedEndpoint)
```

---

## Mocking & Testing

Whenever possible utilize `HTTPRequestPerformer` instead of directly calling `URLSession.shared.send(endpoint)`, this will allow you to avoid networking within unit tests with an implementation such as:
```swift
final class MockPerformer: HTTPRequestPerformer, @unchecked Sendable {
    let handler: ((URLRequest) async throws -> (Data, URLResponse))

    init(handler: @escaping (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        return try await handler(request)
    }
}
```

---

## License

This package is released under the MIT License.
