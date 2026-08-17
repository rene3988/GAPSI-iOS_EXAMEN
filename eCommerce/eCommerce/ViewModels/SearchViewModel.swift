//
//  SearchViewModel.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

@MainActor
final class SearchViewModel {

    enum State {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    private(set) var state: State = .idle

    private let historyManager = SearchHistoryManager()

    private let walmartService: WalmartServiceProtocol

    private(set) var products: [WalmartProductDTO] = []

    private(set) var currentKeyword = ""

    private(set) var currentPage = 0

    private(set) var isLoading = false

    private(set) var hasMorePages = true

    private var searchTask: Task<Void, Never>?

    private let minimumSearchLength = 2

    var onStateChange: (() -> Void)?

    init(walmartService: WalmartServiceProtocol) {
        self.walmartService = walmartService
    }

    deinit {
        searchTask?.cancel()
    }
}

extension SearchViewModel {

    func history() -> [String] {
        historyManager.getHistory()
    }
    
    func search(keyword: String) {

        let keyword = keyword
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard keyword.count >= minimumSearchLength else {
            return
        }

        historyManager.save(keyword)
        
        searchTask?.cancel()

        products.removeAll()

        currentKeyword = keyword
        currentPage = 0
        hasMorePages = true

        updateState(.loading)

        searchTask = Task { [weak self] in

            guard let self else {
                return
            }

            await self.loadPage(
                page: 1,
                replacingProducts: true
            )
        }
    }
}

extension SearchViewModel {

    func loadNextPage() {

        guard !isLoading else {
            return
        }

        guard hasMorePages else {
            return
        }

        guard !currentKeyword.isEmpty else {
            return
        }

        let nextPage = currentPage + 1

        searchTask = Task { [weak self] in

            guard let self else {
                return
            }

            await self.loadPage(
                page: nextPage,
                replacingProducts: false
            )
        }
    }
}

extension SearchViewModel {

    func clearSearch() {

        searchTask?.cancel()
        searchTask = nil

        products.removeAll()

        currentKeyword = ""
        currentPage = 0
        hasMorePages = true
        isLoading = false

        updateState(.idle)
    }
}

private extension SearchViewModel {

    func loadPage(
        page: Int,
        replacingProducts: Bool
    ) async {

        guard !Task.isCancelled else {
            return
        }

        guard !isLoading || replacingProducts else {
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {

            let response = try await walmartService.searchProducts(
                keyword: currentKeyword,
                page: page
            )

            guard !Task.isCancelled else {
                return
            }

            let newProducts = response.products

            if replacingProducts {
                products = newProducts
            } else {
                products.append(contentsOf: newProducts)
            }

            currentPage = page

            hasMorePages = !newProducts.isEmpty

            if products.isEmpty {
                updateState(.empty)
            } else {
                updateState(.loaded)
            }

        } catch is CancellationError {

            return

        } catch {

            updateState(
                .error("Something went wrong. Please try again.")
            )

            print("Search error:", error)
        }
    }

    func updateState(_ newState: State) {
        state = newState
        onStateChange?()
    }
}
