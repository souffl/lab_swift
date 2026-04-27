import UIKit

final class ShopCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ShopCollectionViewCell"

    private enum Constants {
        static let imageSize: CGFloat = 72
        static let horizontalSpacing: CGFloat = 12
        static let verticalInset: CGFloat = 10
        static let horizontalInset: CGFloat = 16
        static let cornerRadius: CGFloat = 12
    }

    private let shopImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .secondaryLabel
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private var imageTask: Cancellable?
    private var representedShopID: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        representedShopID = nil
        shopImageView.image = UIImage(systemName: "photo")
        titleLabel.text = nil
        statusLabel.text = nil
        statusLabel.textColor = .secondaryLabel
    }

    func configure(with viewModel: ShopCellViewModel, imageLoader: ImageLoading) {
        representedShopID = viewModel.id
        titleLabel.text = viewModel.title
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.isOpen ? .systemGreen : .systemRed

        imageTask?.cancel()
        imageTask = nil
        shopImageView.image = UIImage(systemName: "photo")

        guard let imageURL = viewModel.imageURL else {
            return
        }

        imageTask = imageLoader.loadImage(from: imageURL) { [weak self] image in
            guard let self, self.representedShopID == viewModel.id else {
                return
            }

            self.shopImageView.image = image ?? UIImage(systemName: "photo")
        }
    }

    private func buildUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 6
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
}
