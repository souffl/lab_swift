import UIKit

final class ShopsListManager: NSObject {
    var onSelectShop: ((String) -> Void)?

    private weak var collectionView: UICollectionView?
    private let imageLoader: ImageLoading
    private var items: [ShopCellViewModel] = []

    init(collectionView: UICollectionView, imageLoader: ImageLoading) {
        self.collectionView = collectionView
        self.imageLoader = imageLoader
        super.init()
        configure(collectionView: collectionView)
    }

    func setItems(_ items: [ShopCellViewModel]) {
        self.items = items
        collectionView?.reloadData()
    }

    private func configure(collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            ShopCollectionViewCell.self,
            forCellWithReuseIdentifier: ShopCollectionViewCell.reuseIdentifier
        )
    }
}

extension ShopsListManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShopCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ShopCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        cell.configure(with: item, imageLoader: imageLoader)
        return cell
    }
}

extension ShopsListManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectShop?(items[indexPath.item].id)
    }
}

extension ShopsListManager: UICollectionViewDelegateFlowLayout {
    private enum Constants {
        static let sectionHorizontalInset: CGFloat = DSSpacing.m
        static let sectionTopInset: CGFloat = DSSpacing.s + DSSpacing.xs
        static let sectionBottomInset: CGFloat = DSSpacing.m
        static let lineSpacing: CGFloat = DSSpacing.s + DSSpacing.xs
        static let itemHeight: CGFloat = 92
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - Constants.sectionHorizontalInset * 2
        return CGSize(width: availableWidth, height: Constants.itemHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: Constants.sectionTopInset,
            left: Constants.sectionHorizontalInset,
            bottom: Constants.sectionBottomInset,
            right: Constants.sectionHorizontalInset
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.lineSpacing
    }
}
