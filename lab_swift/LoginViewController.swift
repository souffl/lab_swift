//
//  LoginViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//
import UIKit

final class LoginViewController: UIViewController {
    private enum Constants {
        static let horizontalPadding: CGFloat = DSSpacing.m
        static let verticalPadding: CGFloat = DSSpacing.l
        static let buttonHeight: CGFloat = DSSpacing.controlHeight
        static let stackSpacing: CGFloat = DSSpacing.s + DSSpacing.xs
    }
    
    private var viewModel: LoginViewModel
    private var router: AppRouter
    private let onLoginSucceeded: (() -> Void)?
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .interactive
        sv.backgroundColor = .clear
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
    
    private lazy var loginTextField: DSTextField = {
        let view = DSTextField()
        view.configure(
            with: DSTextField.Model(
                title: "Логин",
                placeholder: "Введите логин",
                isSecure: false,
                returnKeyType: .next
            )
        )
        view.textField.delegate = self
        view.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return view
    }()
    
    private lazy var passwordTextField: DSTextField = {
        let view = DSTextField()
        view.configure(
            with: DSTextField.Model(
                title: "Пароль",
                placeholder: "Введите пароль",
                isSecure: true,
                returnKeyType: .done
            )
        )
        view.textField.delegate = self
        view.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return view
    }()
    
    private lazy var loginButton: DSButton = {
        let loginButton = DSButton(style: .primary)
        loginButton.configure(title: "Войти")
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return loginButton
    }()
   
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = DSTypography.caption()
        label.textColor = DS.palette.errorText
        label.numberOfLines = 0
        label.isHidden = true
        return label
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
        configureNavigation()
        
        buildUI()
        bindViewModel()
        setupKeyboardHandling()
        
        loginTextField.textField.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func buildUI() {
        view.backgroundColor = DS.palette.background
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
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            loginButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(buttonContainer)
        stackView.addArrangedSubview(errorLabel)
        
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
    
    private func bindViewModel() {
        viewModel.onLoginFailed = { [weak self] message in
            guard let self else { return }
            
            if let message {
                self.setLoading(false)
                if message == "Пустая строка" {
                    self.applyEmptyCredentialsErrors()
                    return
                }
                self.showError(message)
            } else {
                self.loginTextField.clearError()
                self.passwordTextField.clearError()
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

    private func configureNavigation() {
        navigationItem.title = "Вход"
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
            self?.applyTheme()
        }

        let darkAction = UIAction(
            title: "Dark",
            state: DS.themeKind == .dark ? .on : .off
        ) { [weak self] _ in
            DS.applyTheme(.dark, window: self?.view.window)
            self?.applyTheme()
        }

        return UIMenu(title: "Палитра", options: .displayInline, children: [warmAction, darkAction])
    }

    private func applyTheme() {
        view.backgroundColor = DS.palette.background
        errorLabel.textColor = DS.palette.errorText
        loginTextField.refreshAppearance()
        passwordTextField.refreshAppearance()
        loginButton.refreshAppearance()
        navigationItem.rightBarButtonItem?.menu = makeThemeMenu()
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
        loginTextField.clearError()
        passwordTextField.clearError()
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

        guard validateCredentials(username: username, password: password) else {
            return
        }
        
        setLoading(true)
        viewModel.login(username: username, password: password)
    }
    
    private func setLoading(_ loading: Bool) {
        loginButton.setLoading(loading)
    }
    
    private func showError(_ message: String) {
        loginTextField.clearError()
        passwordTextField.clearError()
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func validateCredentials(username: String, password: String) -> Bool {
        let isUsernameEmpty = username.isEmpty
        let isPasswordEmpty = password.isEmpty

        guard isUsernameEmpty || isPasswordEmpty else {
            loginTextField.clearError()
            passwordTextField.clearError()
            errorLabel.isHidden = true
            errorLabel.text = nil
            return true
        }

        applyEmptyCredentialsErrors(
            isUsernameEmpty: isUsernameEmpty,
            isPasswordEmpty: isPasswordEmpty
        )
        return false
    }

    private func applyEmptyCredentialsErrors() {
        let username = loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        applyEmptyCredentialsErrors(
            isUsernameEmpty: username.isEmpty,
            isPasswordEmpty: password.isEmpty
        )
    }

    private func applyEmptyCredentialsErrors(isUsernameEmpty: Bool, isPasswordEmpty: Bool) {
        loginTextField.setError(isUsernameEmpty ? "Введите логин" : nil)
        passwordTextField.setError(isPasswordEmpty ? "Введите пароль" : nil)
        errorLabel.text = "Заполните обязательные поля"
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
        if textField === loginTextField.textField {
            passwordTextField.textField.becomeFirstResponder()
            return false
        }
        
        if textField === passwordTextField.textField {
            attemptLogin()
            return false
        }
        
        return true
    }
}
