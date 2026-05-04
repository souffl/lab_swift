import Foundation

struct BDUIScreenConfig {
    let title: String
    let endpointPath: String
    let httpMethod: String
    let headers: [String: String]
    let body: Data?

    init(
        title: String,
        endpointPath: String,
        httpMethod: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.title = title
        self.endpointPath = endpointPath
        self.httpMethod = httpMethod
        self.headers = headers
        self.body = body
    }
}
