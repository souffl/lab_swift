import UIKit

final class BDUIViewController: UIViewController {
    private let viewModel: BDUIScreenViewModel
    private let mapper: BDUIViewMapping
    private let actionHandler: BDUIActionHandling
    private let screenTitle: String

    private lazy var screenView: BDUIScreenView = {
        let view = BDUIScreenView(
            viewModel: viewModel,
            mapper: mapper,
            actionHandler: actionHandler
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(
        title: String,
        viewModel: BDUIScreenViewModel,
        mapper: BDUIViewMapping,
        actionHandler: BDUIActionHandling
    ) {
        self.screenTitle = title
        self.viewModel = viewModel
        self.mapper = mapper
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = screenTitle
        view.backgroundColor = DS.palette.background

        view.addSubview(screenView)

        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            screenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            screenView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        screenView.start()
    }
}
