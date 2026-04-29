import UIKit

final class DSTextField: UIView {
    enum State {
        struct Field {
            let title: String?
            let placeholder: String?
            let text: String?
            let isSecure: Bool
            let isEnabled: Bool
            let returnKeyType: UIReturnKeyType
            let autocapitalizationType: UITextAutocapitalizationType
            let autocorrectionType: UITextAutocorrectionType

            init(
                title: String? = nil,
                placeholder: String? = nil,
                text: String? = nil,
                isSecure: Bool = false,
                isEnabled: Bool = true,
                returnKeyType: UIReturnKeyType = .default,
                autocapitalizationType: UITextAutocapitalizationType = .none,
                autocorrectionType: UITextAutocorrectionType = .no
            ) {
                self.title = title
                self.placeholder = placeholder
                self.text = text
                self.isSecure = isSecure
                self.isEnabled = isEnabled
                self.returnKeyType = returnKeyType
                self.autocapitalizationType = autocapitalizationType
                self.autocorrectionType = autocorrectionType
            }
        }

        case content(Field)
        case withError(String)
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


    private var lastContent: State.Field?

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

    func configure(_ state: State) {
        switch state {
        case .content(let field):
            applyFieldContent(field)
            applyErrorMessage(nil)
            lastContent = field
            refreshAppearance()

        case .withError(let message):
            guard let base = lastContent else { return }
            let field = Self.fieldMergingCurrentText(from: base, text: textField.text)
            applyFieldContent(field)
            applyErrorMessage(message)
            refreshAppearance()
        }
    }

    private static func fieldMergingCurrentText(from base: State.Field, text: String?) -> State.Field {
        State.Field(
            title: base.title,
            placeholder: base.placeholder,
            text: text,
            isSecure: base.isSecure,
            isEnabled: base.isEnabled,
            returnKeyType: base.returnKeyType,
            autocapitalizationType: base.autocapitalizationType,
            autocorrectionType: base.autocorrectionType
        )
    }

    private func applyFieldContent(_ model: State.Field) {
        titleLabel.text = model.title
        titleLabel.isHidden = model.title?.isEmpty ?? true

        textField.placeholder = model.placeholder
        textField.text = model.text
        textField.isSecureTextEntry = model.isSecure
        textField.isEnabled = model.isEnabled
        textField.returnKeyType = model.returnKeyType
        textField.autocapitalizationType = model.autocapitalizationType
        textField.autocorrectionType = model.autocorrectionType
    }

    private func applyErrorMessage(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message?.isEmpty ?? true
    }

    private func refreshAppearance() {
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
