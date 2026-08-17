//
//  SearchViewModel.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

@MainActor
final class SearchViewModel {

    private let walmartService: WalmartServiceProtocol

    private(set) var products: [WalmartProductDTO] = []

    private(set) var currentPage = 0
    private(set) var isLoading = false
    private(set) var hasMorePages = true

    private var currentKeyword = ""

    init(walmartService: WalmartServiceProtocol) {
        self.walmartService = walmartService
    }

    func search(keyword: String) async {

        let keyword = keyword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !keyword.isEmpty else {
            return
        }

        currentKeyword = keyword
        currentPage = 1
        hasMorePages = true
        products.removeAll()

        await loadPage()
    }

    func loadNextPage() async {

        guard !isLoading else {
            return
        }

        guard hasMorePages else {
            return
        }

        currentPage += 1

        await loadPage()
    }

    private func loadPage() async {

        guard !isLoading else {
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await walmartService.searchProducts(
                keyword: currentKeyword,
                page: currentPage
            )

            products.append(contentsOf: response.products)

            if response.products.isEmpty {
                hasMorePages = false
            }

        } catch {
            print("Search error: \(error)")
        }
    }
}
