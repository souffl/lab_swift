import UIKit

final class ShopCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ShopCollectionViewCell"

    private enum Constants {
        static let imageSize: CGFloat = 72
        static let horizontalSpacing: CGFloat = DSSpacing.s + DSSpacing.xs
        static let verticalInset: CGFloat = DSSpacing.s + 2
        static let horizontalInset: CGFloat = DSSpacing.m
        static let imageCornerRadius: CGFloat = DSSpacing.cornerRadiusMedium
        static let cardCornerRadius: CGFloat = DSSpacing.cornerRadiusLarge
        static let textStackSpacing: CGFloat = DSSpacing.xs + 2
        static let placeholderImageName = "photo"
    }

    private let shopImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.backgroundColor = DS.palette.background
        imageView.tintColor = DS.palette.iconMuted
        imageView.image = UIImage(systemName: Constants.placeholderImageName)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.headline()
        label.textColor = DS.palette.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypography.captionMedium()
        label.textColor = DS.palette.textSecondary
        return label
    }()

    private var imageTask: Cancellable?
    private var representedShopID: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        refreshAppearance()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .dsThemeDidChange,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        representedShopID = nil
        shopImageView.image = UIImage(systemName: Constants.placeholderImageName)
        titleLabel.text = nil
        statusLabel.text = nil
        refreshAppearance()
    }

    func configure(with viewModel: ShopCellViewModel, imageLoader: ImageLoading) {
        refreshAppearance()
        representedShopID = viewModel.id
        titleLabel.text = viewModel.title
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.isOpen
            ? DS.palette.statusPositive
            : DS.palette.statusNegative

        imageTask?.cancel()
        imageTask = nil
        shopImageView.image = UIImage(systemName: Constants.placeholderImageName)

        guard let imageURL = viewModel.imageURL else {
            return
        }

        imageTask = imageLoader.loadImage(from: imageURL) { [weak self] image in
            guard let self, self.representedShopID == viewModel.id else {
                return
            }

            self.shopImageView.image = image ?? UIImage(systemName: Constants.placeholderImageName)
        }
    }

    private func buildUI() {
        contentView.layer.cornerRadius = Constants.cardCornerRadius
        contentView.layer.masksToBounds = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = Constants.textStackSpacing
        textStack.alignment = .leading

        contentView.addSubview(shopImageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            shopImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            shopImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            shopImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.verticalInset),
            shopImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            shopImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            textStack.leadingAnchor.constraint(equalTo: shopImageView.trailingAnchor, constant: Constants.horizontalSpacing),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            textStack.centerYAnchor.constraint(equalTo: shopImageView.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.verticalInset),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: Constants.verticalInset)
        ])
    }

    private func refreshAppearance() {
        contentView.backgroundColor = DS.palette.surface
        shopImageView.backgroundColor = DS.palette.background
        shopImageView.tintColor = DS.palette.iconMuted
        titleLabel.textColor = DS.palette.textPrimary
        statusLabel.textColor = DS.palette.textSecondary
    }

    @objc
    private func themeDidChange() {
        refreshAppearance()
    }
}
