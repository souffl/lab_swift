import UIKit

protocol ImageLoading: AnyObject {
    @discardableResult
    func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}

final class URLSessionImageLoader: ImageLoading {
    private let session: URLSession
    private let cache: URLCache

    init(cache: URLCache = .shared) {
        self.cache = cache

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: configuration)
    }

    @discardableResult
    func loadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) -> Cancellable? {
        let request = URLRequest(url: url)

        if
            let cachedResponse = cache.cachedResponse(for: request),
            let image = UIImage(data: cachedResponse.data)
        {
            DispatchQueue.main.async {
                completion(image)
            }
            return nil
        }

        let task = session.dataTask(with: request) { [cache] data, response, _ in
            let image = data.flatMap(UIImage.init(data:))

            if let data, let response {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedResponse, for: request)
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()

        return URLSessionTaskWrapper(task: task)
    }
}

private struct URLSessionTaskWrapper: Cancellable {
    let task: URLSessionTask

    func cancel() {
        task.cancel()
    }
}
