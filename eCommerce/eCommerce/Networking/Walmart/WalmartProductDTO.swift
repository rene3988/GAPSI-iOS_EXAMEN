//
//  WalmartProductDTO.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

struct WalmartProductDTO: Decodable {

    let name: String?
    let image: String?
    let priceInfo: PriceInfo?

    var displayName: String {
        name ?? "Product without name"
    }

    var thumbnailURL: URL? {
        guard let image else {
            return nil
        }

        return URL(string: image)
    }

    var price: String {
        priceInfo?
            .priceDetails?
            .priceLines?
            .first(where: {
                $0.lineType == "CURRENT_PRICE"
            })?
            .values?
            .first?
            .value ?? "N/A"
    }
}

struct PriceInfo: Decodable {
    let priceDetails: PriceDetails?
}

struct PriceDetails: Decodable {
    let currency: String?
    let priceLines: [PriceLine]?
}

struct PriceLine: Decodable {
    let lineType: String?
    let values: [PriceValue]?
}

struct PriceValue: Decodable {
    let key: String?
    let value: String?
}
