import Foundation

protocol BDUIScreenLoading {
    func load(config: BDUIScreenConfig) async throws -> BDUIView
}

protocol BDUIScreenRequestBuilding {
    func makeRequest(config: BDUIScreenConfig) throws -> URLRequest
}

enum BDUIScreenLoadError: Error {
    case invalidPath
    case invalidResponse
    case httpStatus(Int)
}

struct EchoAPIConfiguration {
    let baseURL: URL
    let routePath: String

    init(
        baseURL: URL = URL(string: "https://alfaitmo.ru")!,
        routePath: String = "/server/echo"
    ) {
        self.baseURL = baseURL
        self.routePath = routePath
    }

    static func fromBundle() -> EchoAPIConfiguration {
        let defaultConfiguration = EchoAPIConfiguration()
        let rawBaseURL = Bundle.main.object(forInfoDictionaryKey: "BDUI_ECHO_BASE_URL") as? String
        let rawRoutePath = Bundle.main.object(forInfoDictionaryKey: "BDUI_ECHO_ROUTE_PATH") as? String

        let parsedBaseURL = rawBaseURL.flatMap(URL.init(string:)) ?? defaultConfiguration.baseURL
        let parsedRoutePath: String
        if let rawRoutePath {
            let trimmedPath = rawRoutePath.trimmingCharacters(in: .whitespacesAndNewlines)
            parsedRoutePath = trimmedPath.isEmpty ? defaultConfiguration.routePath : trimmedPath
        } else {
            parsedRoutePath = defaultConfiguration.routePath
        }

        return EchoAPIConfiguration(baseURL: parsedBaseURL, routePath: parsedRoutePath)
    }
}

struct EchoScreenRequestBuilder: BDUIScreenRequestBuilding {
    let configuration: EchoAPIConfiguration

    init(configuration: EchoAPIConfiguration = .fromBundle()) {
        self.configuration = configuration
    }

    func makeRequest(config: BDUIScreenConfig) throws -> URLRequest {
        let trimmedPath = config.endpointPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            throw BDUIScreenLoadError.invalidPath
        }

        let normalizedRoutePath = configuration.routePath.hasPrefix("/")
            ? String(configuration.routePath.dropFirst())
            : configuration.routePath
        let normalizedScreenPath = trimmedPath.hasPrefix("/")
            ? String(trimmedPath.dropFirst())
            : trimmedPath

        let url = configuration.baseURL
            .appendingPathComponent(normalizedRoutePath)
            .appendingPathComponent(normalizedScreenPath)
        var request = URLRequest(url: url)
        request.httpMethod = config.httpMethod
        request.httpBody = config.body
        for (name, value) in config.headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }
}

struct HTTPBDUIScreenLoader: BDUIScreenLoading {
    let requestBuilder: BDUIScreenRequestBuilding
    let decoder: JSONDecoder
    let session: URLSession

    init(
        requestBuilder: BDUIScreenRequestBuilding = EchoScreenRequestBuilder(),
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared
    ) {
        self.requestBuilder = requestBuilder
        self.decoder = decoder
        self.session = session
    }

    func load(config: BDUIScreenConfig) async throws -> BDUIView {
        let request = try requestBuilder.makeRequest(config: config)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BDUIScreenLoadError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw BDUIScreenLoadError.httpStatus(httpResponse.statusCode)
        }

        return try decoder.decode(BDUIView.self, from: data)
    }
}
