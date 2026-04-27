//
//  CatalogViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//

import UIKit

final class CatalogViewController: UIViewController {
    private let viewModel: ShopCatalogViewModel
    private let router: AppRouter
    private let imageLoader: ImageLoading

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        return collectionView
    }()

    private lazy var listManager = ShopsListManager(collectionView: collectionView, imageLoader: imageLoader)

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()

    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Повторить"

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()

    private lazy var errorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [errorLabel, retryButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isHidden = true
        return stackView
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = "Поиск магазинов"
        controller.searchBar.autocapitalizationType = .none
        return controller
    }()

    init(
        viewModel: ShopCatalogViewModel,
        router: AppRouter,
        imageLoader: ImageLoading = URLSessionImageLoader()
    ) {
        self.viewModel = viewModel
        self.router = router
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        bindViewModel()

        Task {
            await viewModel.loadShops()
        }
    }

    private func buildUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Магазины"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        view.addSubview(errorStackView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            errorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bindViewModel() {
        listManager.onSelectShop = { [weak self] id in
            self?.viewModel.selectShop(id: id)
        }

        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }

        viewModel.onShopSelected = { [weak self] shop in
            self?.router.showShop(shop)
        }
    }

    private func render(_ state: ShopCatalogState) {
        switch state {
        case .idle:
            setLoading(false)
            showCollection(false)
            showEmpty(text: nil)
            showError(message: nil)
        case .loading:
            setLoading(true)
            showCollection(false)
            showEmpty(text: nil)
            showError(message: nil)
        case .content(let items):
            setLoading(false)
            listManager.setItems(items)
            showCollection(true)
            showEmpty(text: nil)
            showError(message: nil)
        case .empty:
            setLoading(false)
            listManager.setItems([])
            showCollection(false)
            showError(message: nil)
            showEmpty(
                text: viewModel.searchQuery.isEmpty
                    ? "Список магазинов пуст"
                    : "По вашему запросу ничего не найдено"
            )
        case .error(let message):
            setLoading(false)
            listManager.setItems([])
            showCollection(false)
            showEmpty(text: nil)
            showError(message: message)
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showCollection(_ isVisible: Bool) {
        collectionView.isHidden = !isVisible
    }

    private func showEmpty(text: String?) {
        emptyLabel.text = text
        emptyLabel.isHidden = text == nil
    }

    private func showError(message: String?) {
        errorLabel.text = message
        errorStackView.isHidden = message == nil
    }

    @objc private func didTapRetry() {
        Task {
            await viewModel.retryLoading()
        }
    }
}

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchQuery(searchController.searchBar.text ?? "")
    }
}
