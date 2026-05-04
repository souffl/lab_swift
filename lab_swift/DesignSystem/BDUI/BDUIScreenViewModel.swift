import Foundation

enum BDUIScreenState {
    case idle
    case loading
    case content(BDUIView)
    case error(String)
}

@MainActor
final class BDUIScreenViewModel {
    private let loader: BDUIScreenLoading
    private let config: BDUIScreenConfig

    private(set) var state: BDUIScreenState = .idle
    var onStateChanged: ((BDUIScreenState) -> Void)?

    init(loader: BDUIScreenLoading, config: BDUIScreenConfig) {
        self.loader = loader
        self.config = config
    }

    func loadScreen() async {
        await load()
    }

    func reloadScreen() async {
        await load()
    }

    private func load() async {
        state = .loading
        onStateChanged?(state)

        do {
            let screen = try await loader.load(config: config)
            state = .content(screen)
        } catch let error as BDUIScreenLoadError {
            state = .error(message(for: error))
        } catch {
            state = .error("Не удалось загрузить экран")
        }

        onStateChanged?(state)
    }

    private func message(for error: BDUIScreenLoadError) -> String {
        switch error {
        case .invalidPath:
            return "Некорректный путь экрана"
        case .invalidResponse:
            return "Сервер вернул некорректный ответ"
        case .httpStatus(let code):
            return "Ошибка сервера: \(code)"
        }
    }
}
