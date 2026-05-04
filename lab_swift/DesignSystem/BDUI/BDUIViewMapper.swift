import UIKit

final class BDUIViewMapper: BDUIViewMapping {
    private let imageLoader: ImageLoading
    private weak var actionHandler: BDUIActionHandling?

    init(
        imageLoader: ImageLoading = URLSessionImageLoader(),
        actionHandler: BDUIActionHandling
    ) {
        self.imageLoader = imageLoader
        self.actionHandler = actionHandler
    }

    func makeView(from model: BDUIView) -> UIView {
        switch model {
        case .stack(let stack):
            return applyStyle(stack.style, to: makeStack(stack))
        case .label(let label):
            return applyStyle(label.style, to: makeLabel(label))
        case .icon(let icon):
            return applyStyle(icon.style, to: makeIcon(icon))
        case .button(let button):
            return applyStyle(button.style, to: makeButton(button))
        case .spacer(let spacer):
            return makeSpacer(spacer)
        case .textField(let field):
            return applyStyle(field.style, to: makeTextField(field))
        case .list(let list):
            return applyStyle(list.style, to: makeList(list))
        case .loadingView(let model):
            return applyStyle(model.style, to: makeLoadingView(model))
        case .emptyView(let model):
            return applyStyle(model.style, to: makeEmptyView(model))
        case .errorView(let model):
            return applyStyle(model.style, to: makeErrorView(model))
        }
    }

    private func makeStack(_ model: BDUIStackView) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = (model.direction ?? .column).axis
        stack.spacing = model.innerSpace ?? 0
        stack.alignment = (model.alignment ?? .fill).stackAlignment
        stack.distribution = (model.distribution ?? .fill).stackDistribution

        if let padding = model.style?.padding {
            stack.isLayoutMarginsRelativeArrangement = true
            stack.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: padding.top ?? 0,
                leading: padding.leading ?? 0,
                bottom: padding.bottom ?? 0,
                trailing: padding.trailing ?? 0
            )
        }

        for child in model.views {
            stack.addArrangedSubview(makeView(from: child))
        }

        return stack
    }

    private func makeLabel(_ model: BDUILabelView) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = model.text.value
        label.font = model.text.typography?.font ?? DSTypography.body()
        label.textColor = model.text.color?.uiColor ?? DS.palette.textPrimary
        label.textAlignment = textAlignment(from: model.text.alignment)
        label.numberOfLines = model.text.numberOfLines ?? 0
        return label
    }

    private func makeIcon(_ model: BDUIIconView) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = model.tint?.uiColor ?? DS.palette.iconMuted
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = DS.palette.surface

        if let size = model.size {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: size),
                imageView.heightAnchor.constraint(equalToConstant: size)
            ])
        }

        if let url = URL(string: model.imageUrl) {
            imageLoader.loadImage(from: url) { [weak imageView] image in
                guard let imageView, let image else {
                    return
                }

                imageView.image = image
            }
        }

        return imageView
    }

    private func makeButton(_ model: BDUIButtonView) -> DSButton {
        let button = DSButton(style: (model.buttonStyle ?? .primary).dsStyle)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(.idle(title: model.text.value))

        let action = model.action
        button.addAction(
            UIAction { [weak self] _ in
                self?.actionHandler?.handle(action)
            },
            for: .touchUpInside
        )

        return button
    }

    private func makeSpacer(_ model: BDUISpacerView) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .clear

        let height = model.height ?? model.size
        let width = model.width ?? model.size

        if let height {
            let constraint = spacer.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
        if let width {
            let constraint = spacer.widthAnchor.constraint(equalToConstant: width)
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }

        return spacer
    }

    private func makeTextField(_ model: BDUITextFieldView) -> DSTextField {
        let field = DSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.configure(
            .content(
                .init(
                    title: model.title,
                    placeholder: model.placeholder,
                    text: model.text,
                    isSecure: model.isSecure ?? false,
                    isEnabled: model.isEnabled ?? true,
                    returnKeyType: returnKeyType(from: model.returnKeyType)
                )
            )
        )
        return field
    }

    private func makeLoadingView(_ model: BDUILoadingView) -> DSLoadingView {
        let view = DSLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(.loading(message: model.message))
        return view
    }

    private func makeEmptyView(_ model: BDUIEmptyView) -> DSEmptyView {
        let view = DSEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let icon = model.iconSystemName.flatMap { UIImage(systemName: $0) }
            ?? UIImage(systemName: "tray")

        view.configure(
            .visible(
                .init(
                    title: model.title,
                    message: model.message,
                    icon: icon
                )
            )
        )
        return view
    }

    private func makeErrorView(_ model: BDUIErrorView) -> DSErrorView {
        let view = DSErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let icon = model.iconSystemName.flatMap { UIImage(systemName: $0) }
            ?? UIImage(systemName: "exclamationmark.triangle")

        let action = model.action ?? .reload
        let onRetry: (() -> Void) = { [weak self] in
            self?.actionHandler?.handle(action)
        }

        view.configure(
            .visible(
                .init(
                    message: model.message,
                    buttonTitle: model.buttonTitle ?? "Повторить",
                    icon: icon,
                    onRetry: onRetry
                )
            )
        )
        return view
    }

    private func makeList(_ model: BDUIListView) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = (model.direction ?? .column).axis
        stack.spacing = model.innerSpace ?? 0
        stack.alignment = (model.alignment ?? .fill).stackAlignment
        stack.distribution = (model.distribution ?? .fill).stackDistribution

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for item in model.items {
            let bindings = item.objectValue ?? [:]
            let resolved = substitute(in: model.template, with: bindings)

            guard
                let data = try? encoder.encode(resolved),
                let view = try? decoder.decode(BDUIView.self, from: data)
            else {
                continue
            }

            stack.addArrangedSubview(makeView(from: view))
        }

        return stack
    }

    private func returnKeyType(from raw: String?) -> UIReturnKeyType {
        switch raw {
        case "done":
            return .done
        case "search":
            return .search
        case "next":
            return .next
        case "go":
            return .go
        case "send":
            return .send
        default:
            return .default
        }
    }

    private func substitute(
        in value: BDUIJSONValue,
        with bindings: [String: BDUIJSONValue]
    ) -> BDUIJSONValue {
        switch value {
        case .string(let raw):
            return resolveString(raw, with: bindings)
        case .array(let array):
            return .array(array.map { substitute(in: $0, with: bindings) })
        case .object(let object):
            var resolved: [String: BDUIJSONValue] = [:]
            for (key, child) in object {
                resolved[key] = substitute(in: child, with: bindings)
            }
            return .object(resolved)
        default:
            return value
        }
    }

    private func resolveString(
        _ raw: String,
        with bindings: [String: BDUIJSONValue]
    ) -> BDUIJSONValue {
        guard raw.contains("{{") else {
            return .string(raw)
        }

        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("{{"), trimmed.hasSuffix("}}") {
            let inner = String(trimmed.dropFirst(2).dropLast(2))
                .trimmingCharacters(in: .whitespaces)
            if !inner.isEmpty, let value = bindings[inner] {
                return value
            }
        }

        var result = raw
        for (key, value) in bindings {
            guard let stringValue = value.stringValue else {
                continue
            }
            result = result.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
        }
        return .string(result)
    }

    private func textAlignment(from raw: String?) -> NSTextAlignment {
        switch raw {
        case "left":
            return .left
        case "center":
            return .center
        case "right":
            return .right
        case "justified":
            return .justified
        case "natural":
            return .natural
        default:
            return .natural
        }
    }

    private func applyStyle(_ style: BDUIStyle?, to view: UIView) -> UIView {
        guard let style else {
            return view
        }

        if let backgroundColor = style.backgroundColor {
            view.backgroundColor = backgroundColor.uiColor
        }

        if let borderColor = style.borderColor {
            view.layer.borderColor = borderColor.uiColor.cgColor
        }
        if let borderWidth = style.borderWidth {
            view.layer.borderWidth = borderWidth
        }

        if let size = style.size {
            if let width = size.width {
                view.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            if let height = size.height {
                view.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }

        let cornerRadius = style.cornerRadius
        let shadow = style.shadow ?? 0

        if let cornerRadius {
            view.layer.cornerRadius = cornerRadius
            view.layer.cornerCurve = .continuous
            view.layer.masksToBounds = shadow <= 0
        }

        guard shadow > 0 else {
            return view
        }

        if cornerRadius == nil {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.18
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = shadow
            view.layer.masksToBounds = false
            return view
        }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.18
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = shadow
        container.layer.masksToBounds = false
        container.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
}
