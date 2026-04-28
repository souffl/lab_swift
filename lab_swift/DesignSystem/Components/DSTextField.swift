import UIKit

final class DSTextField: UIView {
    struct Model {
        let title: String?
        let placeholder: String?
        let text: String?
        let error: String?
        let isSecure: Bool
        let isEnabled: Bool
        let returnKeyType: UIReturnKeyType
        let autocapitalizationType: UITextAutocapitalizationType
        let autocorrectionType: UITextAutocorrectionType

        init(
            title: String? = nil,
            placeholder: String? = nil,
            text: String? = nil,
            error: String? = nil,
            isSecure: Bool = false,
            isEnabled: Bool = true,
            returnKeyType: UIReturnKeyType = .default,
            autocapitalizationType: UITextAutocapitalizationType = .none,
            autocorrectionType: UITextAutocorrectionType = .no
        ) {
            self.title = title
            self.placeholder = placeholder
            self.text = text
            self.error = error
            self.isSecure = isSecure
            self.isEnabled = isEnabled
            self.returnKeyType = returnKeyType
            self.autocapitalizationType = autocapitalizationType
            self.autocorrectionType = autocorrectionType
        }
    }

    private enum Constants {
        static let stackSpacing: CGFloat = DSSpacing.xs
        static let fieldHorizontalInset: CGFloat = DSSpacing.s + DSSpacing.xs
    }

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.fieldTitle()
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.caption()
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField, errorLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
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

    var text: String? {
        textField.text
    }

    func configure(with model: Model) {
        titleLabel.text = model.title
        titleLabel.isHidden = model.title?.isEmpty ?? true

        textField.placeholder = model.placeholder
        textField.text = model.text
        textField.isSecureTextEntry = model.isSecure
        textField.isEnabled = model.isEnabled
        textField.returnKeyType = model.returnKeyType
        textField.autocapitalizationType = model.autocapitalizationType
        textField.autocorrectionType = model.autocorrectionType

        setError(model.error)
        refreshAppearance()
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message?.isEmpty ?? true
    }

    func clearError() {
        setError(nil)
    }

    func refreshAppearance() {
        titleLabel.textColor = DS.palette.textSecondary
        errorLabel.textColor = DS.palette.errorText
        textField.textColor = DS.palette.textPrimary
        textField.tintColor = DS.palette.primary
        textField.backgroundColor = DS.palette.surface
        textField.layer.borderWidth = 1
        textField.layer.borderColor = (errorLabel.isHidden ? DS.palette.border : DS.palette.error).cgColor
        textField.layer.cornerRadius = DSSpacing.cornerRadiusMedium
        textField.layer.cornerCurve = .continuous
        textField.layoutMargins = UIEdgeInsets(top: 0, left: Constants.fieldHorizontalInset, bottom: 0, right: Constants.fieldHorizontalInset)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: DSSpacing.controlHeight)
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
