import UIKit

final class ShopDetailsViewController: UIViewController {
    private let shop: Shop
    private let makeBDUIScreenView: () -> BDUIScreenView

    private enum Constants {
        static let horizontalInset: CGFloat = DSSpacing.l
        static let stackSpacing: CGFloat = DSSpacing.s
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.title()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.numberOfLines = 0
        return label
    }()

    private lazy var hoursLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.numberOfLines = 0
        return label
    }()

    private lazy var detailsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, locationLabel, hoursLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    private lazy var bduiScreenView: BDUIScreenView = {
        let view = makeBDUIScreenView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(
        shop: Shop,
        makeBDUIScreenView: @escaping () -> BDUIScreenView
    ) {
        self.shop = shop
        self.makeBDUIScreenView = makeBDUIScreenView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        configureNavigation()
        refreshAppearance()

        bduiScreenView.start()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func buildUI() {
        view.addSubview(detailsContainer)
        detailsContainer.addSubview(stackView)
        view.addSubview(bduiScreenView)

        NSLayoutConstraint.activate([
            detailsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: detailsContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: detailsContainer.leadingAnchor, constant: Constants.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: detailsContainer.trailingAnchor, constant: -Constants.horizontalInset),
            stackView.bottomAnchor.constraint(equalTo: detailsContainer.bottomAnchor),

            bduiScreenView.topAnchor.constraint(equalTo: detailsContainer.bottomAnchor, constant: DSSpacing.m),
            bduiScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bduiScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bduiScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .dsThemeDidChange,
            object: nil
        )
    }

    private func configureNavigation() {
        navigationItem.title = shop.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Тема",
            image: nil,
            primaryAction: nil,
            menu: makeThemeMenu()
        )
    }

    private func makeThemeMenu() -> UIMenu {
        let warmAction = UIAction(
            title: "Warm",
            state: DS.themeKind == .warm ? .on : .off
        ) { [weak self] _ in
            DS.applyTheme(.warm, window: self?.view.window)
            self?.refreshAppearance()
            self?.navigationItem.rightBarButtonItem?.menu = self?.makeThemeMenu()
        }

        let darkAction = UIAction(
            title: "Dark",
            state: DS.themeKind == .dark ? .on : .off
        ) { [weak self] _ in
            DS.applyTheme(.dark, window: self?.view.window)
            self?.refreshAppearance()
            self?.navigationItem.rightBarButtonItem?.menu = self?.makeThemeMenu()
        }

        return UIMenu(title: "Палитра", options: .displayInline, children: [warmAction, darkAction])
    }

    private func refreshAppearance() {
        view.backgroundColor = DS.palette.background
        detailsContainer.backgroundColor = DS.palette.background
        titleLabel.textColor = DS.palette.textPrimary
        locationLabel.textColor = DS.palette.textSecondary
        hoursLabel.textColor = DS.palette.textSecondary
    }

    @objc
    private func themeDidChange() {
        refreshAppearance()
        navigationItem.rightBarButtonItem?.menu = makeThemeMenu()
    }
}
