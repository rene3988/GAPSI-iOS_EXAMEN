//
//  APIConfiguration.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

enum APIConfiguration {

    static var rapidAPIKey: String {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "RAPID_API_KEY"
        ) as? String,
        !key.isEmpty
        else {
            fatalError("RAPID_API_KEY no está configurada.")
        }

        return key
    }
}
