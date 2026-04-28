//
//  DSEmptyView.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 28.04.2026.
//

import UIKit

final class DSEmptyView: UIView {
    struct Model {
        let title: String
        let message: String?
        let icon: UIImage?

        init(title: String, message: String? = nil, icon: UIImage? = UIImage(systemName: "tray")) {
            self.title = title
            self.message = message
            self.icon = icon
        }
    }

    private enum Constants {
        static let stackSpacing: CGFloat = DSSpacing.s
        static let iconSide: CGFloat = DSIconSize.large
        static let horizontalInset: CGFloat = DSSpacing.l
    }

    private let iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = DS.palette.iconMuted
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.headline()
        label.textColor = DS.palette.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.body()
        label.textColor = DS.palette.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: Model) {
        titleLabel.text = model.title
        messageLabel.text = model.message
        messageLabel.isHidden = model.message?.isEmpty ?? true

        iconView.image = model.icon
        iconView.isHidden = model.icon == nil
    }

    func refreshAppearance() {
        backgroundColor = .clear
        iconView.tintColor = DS.palette.iconMuted
        titleLabel.textColor = DS.palette.textPrimary
        messageLabel.textColor = DS.palette.textSecondary
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(stackView)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSide),
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSide),

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
    private func themeDidChange() {
        refreshAppearance()
    }
}
