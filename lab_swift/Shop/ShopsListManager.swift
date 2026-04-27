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
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInset: CGFloat = 16
        let availableWidth = collectionView.bounds.width - horizontalInset * 2
        return CGSize(width: availableWidth, height: 92)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
}
