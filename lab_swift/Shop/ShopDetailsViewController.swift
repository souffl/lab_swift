import UIKit

final class ShopDetailsViewController: UIViewController {
    private let shop: Shop

    private enum Constants {
        static let horizontalInset: CGFloat = DSSpacing.l
        static let stackSpacing: CGFloat = DSSpacing.s
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.title()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.numberOfLines = 0
        return label
    }()

    private let hoursLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.numberOfLines = 0
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, locationLabel, hoursLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    init(shop: Shop) {
        self.shop = shop
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        configureContent()
        configureNavigation()
        refreshAppearance()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func buildUI() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .dsThemeDidChange,
            object: nil
        )
    }

    private func configureContent() {
        titleLabel.text = "Детали магазина"
        locationLabel.text = shop.location
        hoursLabel.text = "Часы работы: \(shop.workHours)"
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
