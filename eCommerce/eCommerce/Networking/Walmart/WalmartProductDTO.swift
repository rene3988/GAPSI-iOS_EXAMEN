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
        
        guard let priceLines = priceInfo?
            .priceDetails?
            .priceLines else {
            return "N/A"
        }
        
        // Primero intentamos precio con descuento
        if let discountedPrice = priceLines
            .first(where: { $0.lineType == "DISCOUNTED_PRICE" })?
            .values?
            .first(where: { $0.key == "PRICE" })?
            .value {
            
            return discountedPrice
        }
        
        // Si no hay descuento, usamos precio actual
        if let currentPrice = priceLines
            .first(where: { $0.lineType == "CURRENT_PRICE" })?
            .values?
            .first(where: { $0.key == "PRICE" })?
            .value {
            
            return currentPrice
        }
        
        return "N/A"
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
