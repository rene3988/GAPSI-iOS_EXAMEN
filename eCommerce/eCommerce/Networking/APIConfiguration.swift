//
//  APIConfiguration.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

protocol APIKeyProviding {
    var apiKey: String { get }
}

final class BundleAPIKeyProvider: APIKeyProviding {

    private let keyName: String

    init(keyName: String = "REMOTE_SERVICE_KEY") {
        self.keyName = keyName
    }

    var apiKey: String {
        guard let encoded = Bundle.main.object(
            forInfoDictionaryKey: keyName
        ) as? String,
        !encoded.isEmpty else {
            fatalError("API key is not configured.")
        }

        guard let data = Data(base64Encoded: encoded),
              let key = String(data: data, encoding: .utf8),
              !key.isEmpty else {
            fatalError("Invalid encoded API key.")
        }

        return key
    }
}

final class APIConfiguration {

    static let shared = APIConfiguration()

    private let keyProvider: APIKeyProviding

    init(keyProvider: APIKeyProviding = BundleAPIKeyProvider()) {
        self.keyProvider = keyProvider
    }

    var serviceKey: String {
        keyProvider.apiKey
    }
}
