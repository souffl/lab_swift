import Foundation

protocol BDUIScreenLoading {
    func load(config: BDUIScreenConfig) async throws -> BDUIView
}


enum BDUIScreenLoadError: Error {
    case invalidPath
    case invalidResponse
    case httpStatus(Int)
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
