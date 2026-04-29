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

    private lazy var loadingView: DSLoadingView = {
        let view = DSLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(.loading(message: "Загружаем магазины..."))
        return view
    }()

    private lazy var emptyView: DSEmptyView = {
        let view = DSEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var errorView: DSErrorView = {
        let view = DSErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.configure(.hidden)
        return view
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
        configureNavigation()

        Task {
            await viewModel.loadShops()
        }
    }

    private func buildUI() {
        view.backgroundColor = DS.palette.background
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(collectionView)
        view.addSubview(loadingView)
        view.addSubview(emptyView)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureNavigation() {
        navigationItem.title = "Магазины"
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
        navigationItem.rightBarButtonItem?.menu = makeThemeMenu()
        collectionView.reloadData()
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
        loadingView.isHidden = !isLoading
    }

    private func showCollection(_ isVisible: Bool) {
        collectionView.isHidden = !isVisible
    }

    private func showEmpty(text: String?) {
        guard let text else {
            emptyView.configure(.hidden)
            emptyView.isHidden = true
            return
        }

        emptyView.configure(.visible(.init(title: text)))
        emptyView.isHidden = false
    }

    private func showError(message: String?) {
        guard let message else {
            errorView.configure(.hidden)
            errorView.isHidden = true
            return
        }

        errorView.configure(
            .visible(
                .init(
                    message: message,
                    onRetry: { [weak self] in
                        self?.didTapRetry()
                    }
                )
            )
        )
        errorView.isHidden = false
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
