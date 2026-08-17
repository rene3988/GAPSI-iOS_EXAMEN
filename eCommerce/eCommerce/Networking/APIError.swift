//
//  APIError.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import Foundation
import Alamofire

enum APIError: LocalizedError {

    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case decodingError
    case networkError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
            case .invalidResponse:
                return "The server response is invalid."

            case .unauthorized:
                return "The request is not authorized."

            case .forbidden:
                return "You do not have permission to access this resource."

            case .notFound:
                return "The requested resource was not found."

            case .serverError:
                return "An error occurred on the server."

            case .decodingError:
                return "The response could not be interpreted."

            case .networkError(let error):
                return error.localizedDescription

            case .unknown(let error):
                return error.localizedDescription
            }
    }

    static func from<T>(
        _ error: AFError,
        response: DataResponse<T, AFError>
    ) -> APIError {

        if let statusCode = response.response?.statusCode {

            switch statusCode {
            case 401:
                return .unauthorized

            case 403:
                return .forbidden

            case 404:
                return .notFound

            case 500...599:
                return .serverError

            default:
                break
            }
        }

        if error.isResponseSerializationError {
            return .decodingError
        }

        if error.isSessionTaskError {
            return .networkError(error)
        }

        return .unknown(error)
    }
}
