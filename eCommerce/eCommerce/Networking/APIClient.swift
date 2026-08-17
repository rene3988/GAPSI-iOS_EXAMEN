//
//  APIClient.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation
import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T
}

final class APIClient: APIClientProtocol {

    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {

        let request = session.request(
            endpoint.url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers
        )

        let response = await request
            .validate()
            .serializingDecodable(T.self)
            .response

        switch response.result {
        case .success(let value):
            return value

        case .failure(let error):
            print("Status code: \(response.response?.statusCode ?? -1)")
            print("Error: \(error)")
            print("Underlying: \(String(describing: error.underlyingError))")

            throw APIError.from(error, response: response)
        }
    }
}
