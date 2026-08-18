//
//  SearchViewController.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import UIKit

@MainActor
final class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var historyTableView: UITableView!
    
    // MARK: - Dependencies
    
    private let viewModel: SearchViewModel
    
    // MARK: - State
    
    private var searchHistory: [String] = []
    
    // MARK: - Init
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureSearchBar()
        configureActivityIndicator()
        configureStateLabel()
        configureHistoryTableView()
        configureViewModel()
        
        handleViewModelState()
    }
}

// MARK: - Configuration

private extension SearchViewController {
    
    func configureViewModel() {
        
        viewModel.onStateChange = { [weak self] in
            self?.handleViewModelState()
        }
    }
    
    func configureSearchBar() {
        
        searchBar.delegate = self
        searchBar.placeholder = "Search products"
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func configureActivityIndicator() {
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    func configureStateLabel() {
        
        stateLabel.textAlignment = .center
        stateLabel.numberOfLines = 0
        stateLabel.isHidden = false
    }
    
    private func configureHistoryTableView() {
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        historyTableView.isHidden = true
        historyTableView.tableFooterView = UIView()
        
        historyTableView.keyboardDismissMode = .onDrag
    }
    
    private func setHistoryVisible(_ visible: Bool) {
        
        guard visible, !searchHistory.isEmpty else {
            historyTableView.isHidden = true
            return
        }
        
        historyTableView.reloadData()
        historyTableView.isHidden = false
    }
    
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

// MARK: - ViewModel State

private extension SearchViewController {
    
    func handleViewModelState() {
        
        switch viewModel.state {
            
        case .idle:
            
            stateLabel.isHidden = false
            
            collectionView.isHidden = true
            collectionView.isUserInteractionEnabled = false
            
            activityIndicator.stopAnimating()
            
            searchBar.isUserInteractionEnabled = true
            
            stateLabel.text = """
            🔍
            
            Search products
            
            Enter a product to start searching.
            """
            
        case .loading:
            stateLabel.isHidden = true
            
            collectionView.isHidden = true
            
            collectionView.isUserInteractionEnabled = false
            
            activityIndicator.startAnimating()
            
            searchBar.isUserInteractionEnabled = false
            
        case .loaded:
            stateLabel.isHidden = true
            
            collectionView.isHidden = false
            
            collectionView.isUserInteractionEnabled = true
            
            activityIndicator.stopAnimating()
            
            searchBar.isUserInteractionEnabled = true
            
            collectionView.reloadData()
            
        case .empty:
            
            collectionView.isHidden = true
            collectionView.isUserInteractionEnabled = false
            
            activityIndicator.stopAnimating()
            
            searchBar.isUserInteractionEnabled = true
            
            stateLabel.isHidden = false
            
            stateLabel.text = """
            No products found
            
            Try searching for another product or brand.
            """
            
        case .error(let message):
            
            collectionView.isHidden = true
            collectionView.isUserInteractionEnabled = false
            
            activityIndicator.stopAnimating()
            
            searchBar.isUserInteractionEnabled = true
            
            stateLabel.isHidden = false
            
            stateLabel.text = """
            Something went wrong
            
            \(message)
            """
        }
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
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
                ProductCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let productCell = cell as? ProductCollectionViewCell else {
            return cell
        }
        
        guard indexPath.item < viewModel.products.count else {
            return cell
        }
        
        let product = viewModel.products[indexPath.item]
        
        productCell.configure(with: product)
        
        return productCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        guard viewModel.canLoadNextPage else {
            return
        }
        
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
    
    func searchBarSearchButtonClicked(
        _ searchBar: UISearchBar
    ) {
        
        let keyword = searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard keyword.count >= 2 else {
            
            stateLabel.isHidden = false
            collectionView.isHidden = true
            
            stateLabel.text = """
            🔍
            
            Search products
            
            Enter at least 2 characters.
            """
            
            return
        }
        
        searchBar.resignFirstResponder()
        
        setHistoryVisible(false)
        
        viewModel.search(keyword: keyword)
    }
    
    func searchBarShouldBeginEditing(
        _ searchBar: UISearchBar
    ) -> Bool {
        
        searchHistory = viewModel.history()
        
        setHistoryVisible(true)
        
        return true
    }
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        
        guard searchText.isEmpty else {
            return
        }
        
        setHistoryVisible(false)
        
        viewModel.clearSearch()
    }
}

// MARK: - UITableViewDataSource

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
        
        guard indexPath.row < searchHistory.count else {
            return cell
        }
        
        cell.textLabel?.text = searchHistory[indexPath.row]
        
        cell.imageView?.image = UIImage(
            systemName: "clock.arrow.circlepath"
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        let keyword = searchHistory[indexPath.row]
        
        searchBar.text = keyword
        
        setHistoryVisible(false)
        
        searchBar.resignFirstResponder()
        
        viewModel.search(keyword: keyword)
    }
}
