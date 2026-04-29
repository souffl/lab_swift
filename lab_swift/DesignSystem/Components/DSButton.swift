

import UIKit

final class DSButton: UIButton {
    enum Style {
        case primary
        case secondary
    }

    enum State {
        case idle(title: String)
        case loading
    }

    private enum Constants {
        static let horizontalInsets = NSDirectionalEdgeInsets(
            top: DSSpacing.s + DSSpacing.xs,
            leading: DSSpacing.m,
            bottom: DSSpacing.s + DSSpacing.xs,
            trailing: DSSpacing.m
        )
    }

    private let style: Style
    private var storedTitle: String?
    private var isLoading = false

    init(style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        setup()
        applyCurrentStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet {
            applyCurrentStyle()
        }
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        if state == .normal {
            storedTitle = title
        }
        super.setTitle(title, for: state)
    }

    func configure(_ state: State) {
        switch state {
        case .idle(let title):
            if isLoading {
                hideActivityIndicator()
                isLoading = false
            }
            storedTitle = title
            super.setTitle(title, for: .normal)
            isEnabled = true
        case .loading:
            guard !isLoading else {
                applyCurrentStyle()
                return
            }
            isLoading = true
            storedTitle = storedTitle ?? title(for: .normal)
            super.setTitle(nil, for: .normal)
            isEnabled = false
            showActivityIndicator()
        }
        applyCurrentStyle()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = DSTypography.button()
        layer.cornerCurve = .continuous
        layer.cornerRadius = DSSpacing.cornerRadiusMedium
        configuration = UIButton.Configuration.plain()

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
    private func themeDidChange() {
        applyCurrentStyle()
    }

    private func showActivityIndicator() {
        if #available(iOS 15.0, *) {
            configuration?.showsActivityIndicator = true
        } else {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.startAnimating()
            addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }

    private func hideActivityIndicator() {
        if #available(iOS 15.0, *) {
            configuration?.showsActivityIndicator = false
        } else {
            subviews
                .compactMap { $0 as? UIActivityIndicatorView }
                .forEach { $0.removeFromSuperview() }
        }
    }

    private func applyCurrentStyle() {
        var config: UIButton.Configuration = {
            switch style {
            case .primary:
                return .filled()
            case .secondary:
                return .plain()
            }
        }()
        config.contentInsets = Constants.horizontalInsets
        config.title = isLoading ? nil : storedTitle

        let palette = DS.palette

        switch style {
        case .primary:
            config.baseBackgroundColor = isEnabled ? palette.primary : palette.primary.withAlphaComponent(0.5)
            config.baseForegroundColor = palette.onPrimary
            layer.borderWidth = 0
            layer.borderColor = nil
        case .secondary:
            config.baseBackgroundColor = .clear
            config.baseForegroundColor = isEnabled ? palette.primary : palette.textSecondary
            layer.borderWidth = 1
            layer.borderColor = (isEnabled ? palette.primary : palette.border).cgColor
        }

        configuration = config
        alpha = isEnabled ? 1 : 0.95
    }
}
