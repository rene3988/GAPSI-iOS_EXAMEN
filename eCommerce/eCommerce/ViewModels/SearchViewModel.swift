//
//  SearchViewModel.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

@MainActor
final class SearchViewModel {
    
    // MARK: - State
    
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }
    
    private(set) var state: State = .idle
    
    private(set) var products: [WalmartProductDTO] = []
    
    private(set) var currentKeyword = ""
    
    private(set) var currentPage = 0
    
    private(set) var isLoading = false
    
    private(set) var hasMorePages = true
    
    // MARK: - Dependencies
    
    private let historyManager = SearchHistoryManager()
    
    private let walmartService: WalmartServiceProtocol
    
    // MARK: - Search
    
    private var searchTask: Task<Void, Never>?
    
    private var searchID = UUID()
    
    private let minimumSearchLength = 2
    
    // MARK: - Callback
    
    var onStateChange: (() -> Void)?
    
    // MARK: - Pagination
    
    var canLoadNextPage: Bool {
        !isLoading &&
        hasMorePages &&
        !currentKeyword.isEmpty
    }
    
    // MARK: - Init
    
    init(walmartService: WalmartServiceProtocol) {
        self.walmartService = walmartService
    }
    
    deinit {
        searchTask?.cancel()
    }
}

// MARK: - Search

extension SearchViewModel {
    
    func search(keyword: String) {
        
        let keyword = keyword
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard keyword.count >= minimumSearchLength else {
            return
        }
        
        // Cancelar búsqueda anterior
        searchTask?.cancel()
        searchTask = nil
        
        // Invalidar cualquier respuesta anterior
        searchID = UUID()
        
        // Limpiar resultados anteriores
        products.removeAll()
        
        // Reset completo
        currentKeyword = keyword
        currentPage = 0
        hasMorePages = true
        isLoading = false
        
        historyManager.save(keyword)
        
        updateState(.loading)
        
        let requestID = searchID
        
        searchTask = Task { [weak self] in
            
            guard let self else {
                return
            }
            
            await self.loadPage(
                page: 1,
                replacingProducts: true,
                searchID: requestID
            )
        }
    }
}

// MARK: - Pagination

extension SearchViewModel {
    
    func loadNextPage() {
        
        guard canLoadNextPage else {
            return
        }
        
        let nextPage = currentPage + 1
        let currentSearchID = searchID
        
        searchTask = Task { [weak self] in
            
            guard let self else {
                return
            }
            
            await self.loadPage(
                page: nextPage,
                replacingProducts: false,
                searchID: currentSearchID
            )
        }
    }
}

// MARK: - History

extension SearchViewModel {
    
    func history() -> [String] {
        historyManager.getHistory()
    }
}

// MARK: - Clear

extension SearchViewModel {
    
    func clearSearch() {
        
        searchTask?.cancel()
        searchTask = nil
        
        // Invalidar cualquier respuesta pendiente
        searchID = UUID()
        
        products.removeAll()
        
        currentKeyword = ""
        currentPage = 0
        hasMorePages = true
        isLoading = false
        
        updateState(.idle)
    }
}

// MARK: - Private

private extension SearchViewModel {
    
    func loadPage(
        page: Int,
        replacingProducts: Bool,
        searchID: UUID
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
        
        let keyword = currentKeyword
        
        do {
            
            let response = try await walmartService.searchProducts(
                keyword: keyword,
                page: page
            )
            
            guard !Task.isCancelled else {
                return
            }
            
            guard searchID == self.searchID else {
                return
            }
            
            guard keyword == currentKeyword else {
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
            
            updateState(
                products.isEmpty
                ? .empty
                : .loaded
            )
            
        } catch is CancellationError {
            
            return
            
        } catch {
            
            guard searchID == self.searchID else {
                return
            }
            
            updateState(
                .error("Something went wrong. Please try again.")
            )
        }
    }
    
    func updateState(_ newState: State) {
        
        state = newState
        
        onStateChange?()
    }
}
