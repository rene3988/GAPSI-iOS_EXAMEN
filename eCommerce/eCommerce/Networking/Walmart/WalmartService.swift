//
//  WalmartService.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

protocol WalmartServiceProtocol {
    func searchProducts(
        keyword: String,
        page: Int
    ) async throws -> WalmartSearchResponse
}

final class WalmartService: WalmartServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func searchProducts(
        keyword: String,
        page: Int
    ) async throws -> WalmartSearchResponse {

        let endpoint = WalmartEndpoint.search(
            keyword: keyword,
            page: page
        )

        return try await apiClient.request(endpoint)
    }
}
