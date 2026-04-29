import UIKit

final class DSErrorView: UIView {
    enum State {
        case hidden

        struct Content {
            let message: String
            let buttonTitle: String
            let icon: UIImage?
            let onRetry: (() -> Void)?

            init(
                message: String,
                buttonTitle: String = "Повторить",
                icon: UIImage? = UIImage(systemName: "exclamationmark.triangle"),
                onRetry: (() -> Void)? = nil
            ) {
                self.message = message
                self.buttonTitle = buttonTitle
                self.icon = icon
                self.onRetry = onRetry
            }
        }

        case visible(Content)
    }

    private enum Constants {
        static let spacing: CGFloat = DSSpacing.s
        static let horizontalInset: CGFloat = DSSpacing.l
        static let iconSize: CGFloat = DSIconSize.large
    }

    private var retryAction: (() -> Void)?

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let retryButton: DSButton = {
        let button = DSButton(style: .primary)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, messageLabel, retryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.spacing
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        refreshAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ state: State) {
        switch state {
        case .hidden:
            retryAction = nil
        case .visible(let content):
            retryAction = content.onRetry
            messageLabel.text = content.message
            iconView.image = content.icon
            iconView.isHidden = content.icon == nil
            retryButton.configure(.idle(title: content.buttonTitle))
        }
        refreshAppearance()
    }

    private func refreshAppearance() {
        backgroundColor = .clear
        messageLabel.textColor = DS.palette.errorText
        iconView.tintColor = DS.palette.error
    }

    private func setupUI() {
        addSubview(stackView)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            retryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),

            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Constants.horizontalInset),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.horizontalInset),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .dsThemeDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func didTapRetry() {
        retryAction?()
    }

    @objc
    private func themeDidChange() {
        refreshAppearance()
    }
}
