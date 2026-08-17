//
//  SearchViewController.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import UIKit

@MainActor
final class SearchViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var historyTableView: UITableView!
    private let viewModel: SearchViewModel

    private let historyManager = SearchHistoryManager()
    private var searchHistory: [String] = []
    
    required init?(coder: NSCoder) {

        let apiClient = APIClient()

        let walmartService = WalmartService(
            apiClient: apiClient
        )

        self.viewModel = SearchViewModel(
            walmartService: walmartService
        )

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureSearchBar()
        configureActivityIndicator()
        configureStateLabel()
        configTableView()
        viewModel.onStateChange = { [weak self] in
               self?.handleViewModelState()
           }

        handleViewModelState()
    }

    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search products"
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
    }

    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    private func configureStateLabel() {

        stateLabel.textAlignment = .center
        stateLabel.numberOfLines = 0
        stateLabel.isHidden = false
    }
    
    private func configTableView(){
        searchHistory = historyManager.getHistory()

        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.isHidden = true
    }
    
    private func handleViewModelState() {

        switch viewModel.state {

        case .idle:
            stateLabel.isHidden = false
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            stateLabel.text = """
            🔍

            Search products

            Enter a product to start searching.
            """

        case .loading:
            stateLabel.isHidden = true
            collectionView.isHidden = false
            activityIndicator.startAnimating()
            searchBar.isUserInteractionEnabled = false

        case .loaded:
            stateLabel.isHidden = true
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            collectionView.reloadData()

        case .empty:
            stateLabel.isHidden = false
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            stateLabel.text = """
            🔍

            No products found

            Try another search term.
            """

        case .error(let message):
            stateLabel.isHidden = false
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            stateLabel.text = """
            ⚠️

            \(message)
            """
        }
    }
    
    private func updateUI() {

        switch viewModel.state {

        case .idle:

            stateLabel.isHidden = false
            stateLabel.text = """
            🔍

            Search products

            Enter at least 2 characters
            to start searching.
            """

            collectionView.isHidden = true

        case .loading:

            stateLabel.isHidden = true
            collectionView.isHidden = false

            activityIndicator.startAnimating()
            searchBar.isUserInteractionEnabled = false

        case .loaded:

            stateLabel.isHidden = true
            collectionView.isHidden = false

            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

        case .empty:

            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            collectionView.isHidden = true
            stateLabel.isHidden = false

            stateLabel.text = """
            🔍

            No products found

            Try another search term.
            """

        case .error(let message):

            activityIndicator.stopAnimating()
            searchBar.isUserInteractionEnabled = true

            collectionView.isHidden = true
            stateLabel.isHidden = false

            stateLabel.text = """
            ⚠️

            \(message)
            """
        }
    }
}

// MARK: - Collection View

private extension SearchViewController {

    func configureCollectionView() {

        collectionView.dataSource = self
        collectionView.delegate = self

        let nib = UINib(
            nibName: ProductCollectionViewCell.reuseIdentifier,
            bundle: nil
        )

        collectionView.register(
            nib,
            forCellWithReuseIdentifier:
                ProductCollectionViewCell.reuseIdentifier
        )

        let layout = UICollectionViewFlowLayout()

        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8

        collectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        viewModel.products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
                ProductCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCollectionViewCell else {

            return UICollectionViewCell()
        }

        let product = viewModel.products[indexPath.item]

        cell.configure(with: product)

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

        let threshold = 5
        let totalProducts = viewModel.products.count

        guard totalProducts > 0 else {
            return
        }

        guard indexPath.item >= totalProducts - threshold else {
            return
        }

        viewModel.loadNextPage()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 8
        let horizontalPadding: CGFloat = 16

        let availableWidth =
            collectionView.bounds.width
            - horizontalPadding * 2
            - spacing

        let width = availableWidth / 2

        return CGSize(
            width: width,
            height: 260
        )
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        historyTableView.isHidden = true
        
        let keyword = searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard keyword.count >= 2 else {
            stateLabel.isHidden = false
            stateLabel.text = """
            🔍

            Search products

            Enter at least 2 characters.
            """
            return
        }

        searchBar.resignFirstResponder()

        viewModel.search(keyword: keyword)
    }
    
    func searchBarShouldBeginEditing(
        _ searchBar: UISearchBar
    ) -> Bool {

        searchHistory = historyManager.getHistory()

        historyTableView.reloadData()

        historyTableView.isHidden = searchHistory.isEmpty

        return true
    }
}

extension SearchViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        searchHistory.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )

        cell.textLabel?.text = searchHistory[indexPath.row]
        cell.imageView?.image = UIImage(
            systemName: "clock.arrow.circlepath"
        )

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let keyword = searchHistory[indexPath.row]

        searchBar.text = keyword
        historyTableView.isHidden = true

        searchBar.resignFirstResponder()

        viewModel.search(keyword: keyword)
    }
}
