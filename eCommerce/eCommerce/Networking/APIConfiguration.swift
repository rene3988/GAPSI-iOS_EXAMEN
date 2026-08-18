//
//  APIConfiguration.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation

enum APIConfiguration {

    static var serviceKey: String {
        guard let encodedKey = Bundle.main.object(
            forInfoDictionaryKey: "REMOTE_SERVICE_KEY"
        ) as? String,
        !encodedKey.isEmpty
        else {
            fatalError("REMOTE_SERVICE_KEY no está configurada.")
        }

        guard let data = Data(base64Encoded: encodedKey),
              let key = String(data: data, encoding: .utf8)
        else {
            fatalError("REMOTE_SERVICE_KEY no es un Base64 válido.")
        }

        return key
    }
}
