//
//  Endpoint.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation
import Alamofire

enum Endpoint {

    case walmartSearch(
        keyword: String,
        page: Int
    )

    var url: URL {
        switch self {
        case .walmartSearch:
            return URL(
                string: "https://axesso-walmart-data-service.p.rapidapi.com/wlm/walmart-search-by-keyword"
            )!
        }
    }

    var method: HTTPMethod {
        switch self {
        case .walmartSearch:
            return .get
        }
    }

    var parameters: Parameters? {
        switch self {
        case .walmartSearch(let keyword, let page):
            return [
                "keyword": keyword,
                "page": page,
                "sortBy": "best_match"
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .walmartSearch:
            return URLEncoding.default
        }
    }

    var headers: HTTPHeaders {
        switch self {
        case .walmartSearch:
            return [
                "x-rapidapi-key": APIConfiguration.serviceKey,
                "x-rapidapi-host": "axesso-walmart-data-service.p.rapidapi.com"
            ]
        }
    }
}
