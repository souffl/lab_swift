import UIKit

final class BDUIScreenView: UIView {
    private enum Constants {
        static let contentInset: CGFloat = DSSpacing.m
    }

    private let viewModel: BDUIScreenViewModel
    private let mapper: BDUIViewMapping
    private let actionHandler: BDUIActionHandling

    private weak var renderedView: UIView?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(
        viewModel: BDUIScreenViewModel,
        mapper: BDUIViewMapping,
        actionHandler: BDUIActionHandling
    ) {
        self.viewModel = viewModel
        self.mapper = mapper
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        backgroundColor = DS.palette.background

        buildLayout()
        bindViewModel()
        observeTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        Task {
            await viewModel.loadScreen()
        }
    }

    private func buildLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentContainer)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.contentInset),
            contentContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Constants.contentInset),
            contentContainer.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Constants.contentInset),
            contentContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.contentInset),
            contentContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * Constants.contentInset)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }

        actionHandler.onReloadRequested = { [weak self] in
            guard let self else {
                return
            }
            Task {
                await self.viewModel.reloadScreen()
            }
        }
    }

    private func observeTheme() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .dsThemeDidChange,
            object: nil
        )
    }

    private func render(_ state: BDUIScreenState) {
        switch state {
        case .idle, .loading:
            renderModel(.loadingView(BDUILoadingView(message: "Загрузка...", style: nil)))
        case .content(let model):
            renderModel(model)
        case .error(let message):
            renderModel(
                .errorView(
                    BDUIErrorView(
                        message: message,
                        buttonTitle: "Повторить",
                        iconSystemName: "exclamationmark.triangle",
                        action: .reload,
                        style: nil
                    )
                )
            )
        }
    }

    private func renderModel(_ model: BDUIView) {
        renderedView?.removeFromSuperview()

        let rendered = mapper.makeView(from: model)
        rendered.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(rendered)

        NSLayoutConstraint.activate([
            rendered.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            rendered.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            rendered.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            rendered.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        renderedView = rendered
    }

    @objc
    private func themeDidChange() {
        backgroundColor = DS.palette.background
        render(viewModel.state)
    }
}
