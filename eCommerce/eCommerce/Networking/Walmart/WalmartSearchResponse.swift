//
//  WalmartSearchResponse.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

import Foundation

import Foundation

struct WalmartSearchResponse: Decodable {

    let item: WalmartItem

    var products: [WalmartProductDTO] {
        item
            .props
            .pageProps
            .initialData
            .searchResult
            .itemStacks
            .flatMap(\.items)
            .filter {
                $0.name != nil
            }
    }
}

struct WalmartItem: Decodable {
    let props: WalmartProps
}

struct WalmartProps: Decodable {
    let pageProps: WalmartPageProps
}

struct WalmartPageProps: Decodable {
    let initialData: WalmartInitialData
}

struct WalmartInitialData: Decodable {
    let searchResult: WalmartSearchResult
}

struct WalmartSearchResult: Decodable {
    let itemStacks: [WalmartItemStack]
}

struct WalmartItemStack: Decodable {
    let items: [WalmartProductDTO]
}

