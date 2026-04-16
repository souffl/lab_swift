//
//  LoginViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//
import UIKit

final class LoginViewController: UIViewController {
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let fieldHeight: CGFloat = 44
        static let buttonHeight: CGFloat = 50
        static let stackSpacing: CGFloat = 12
    }
    
    private var viewModel: LoginViewModel
    private var router: AppRouter
    private let onLoginSucceeded: (() -> Void)?
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = Constants.stackSpacing
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    private lazy var loginTextField: UITextField = {
        makeTextField(
            placeholder: "Логин",
            isSecure: false,
            returnKey: .next
        )
    }()
    
    private lazy var passwordTextField: UITextField = {
        makeTextField(
            placeholder: "Пароль",
            isSecure: true,
            returnKey: .done
        )
    }()
    
    private lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Войти"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        
        let button = UIButton(type: .system)
        button.configuration = config
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private weak var activeTextField: UITextField?
    private var originalScrollViewInsetBottom: CGFloat = 0
    
    init(viewModel: LoginViewModel, router: AppRouter, onLoginSucceeded: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.router = router
        self.onLoginSucceeded = onLoginSucceeded
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Вход"
        
        buildUI()
        bindViewModel()
        setupKeyboardHandling()
        
        loginTextField.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func buildUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(loginTextField)
        stackView.addArrangedSubview(passwordTextField)
        
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonContainer.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        buttonContainer.addSubview(loginButton)
        buttonContainer.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            loginButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor)
        ])
        
        stackView.addArrangedSubview(buttonContainer)
        stackView.addArrangedSubview(errorLabel)
        
        [loginTextField, passwordTextField].forEach { tf in
            NSLayoutConstraint.activate([
                tf.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
            ])
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.verticalPadding),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * Constants.horizontalPadding),
        ])
    }
    
    private func makeTextField(placeholder: String, isSecure: Bool, returnKey: UIReturnKeyType) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = returnKey
        tf.isSecureTextEntry = isSecure
        tf.delegate = self
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }
    
    private func bindViewModel() {
        viewModel.onLoginFailed = { [weak self] message in
            guard let self else { return }
            
            if let message {
                self.setLoading(false)
                self.showError(message)
            } else {
                self.errorLabel.text = nil
                self.errorLabel.isHidden = true
            }
        }
        
        viewModel.onLoginSucceeded = { [weak self] in
            self?.setLoading(false)
            self?.router.showShopCatalog()
            self?.onLoginSucceeded?()
        }
    }
    
    private func setupKeyboardHandling() {
        originalScrollViewInsetBottom = scrollView.contentInset.bottom
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func textDidChange() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }
    
    @objc private func didTapLogin() {
        attemptLogin()
    }
    
    private func attemptLogin() {
        view.endEditing(true)
        
        let username = loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        
        setLoading(true)
        viewModel.login(username: username, password: password)
    }
    
    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        
        let keyboardHeightInView = view.convert(keyboardFrameEnd, from: nil).height
        let bottomInset = max(0, keyboardHeightInView - view.safeAreaInsets.bottom) + 16
        
        scrollView.contentInset.bottom = originalScrollViewInsetBottom + bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = originalScrollViewInsetBottom + bottomInset
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.scrollToActiveTextField(animated: false)
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.scrollView.contentInset.bottom = self.originalScrollViewInsetBottom
            self.scrollView.verticalScrollIndicatorInsets.bottom = self.originalScrollViewInsetBottom
        })
    }
    
    private func scrollToActiveTextField(animated: Bool) {
        guard let tf = activeTextField else { return }
        let rectInScroll = scrollView.convert(tf.bounds, from: tf)
        scrollView.scrollRectToVisible(rectInScroll.insetBy(dx: 0, dy: -20), animated: animated)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        scrollToActiveTextField(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === loginTextField {
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        if textField === passwordTextField {
            attemptLogin()
            return false
        }
        
        return true
    }
}
