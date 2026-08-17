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
            return "La respuesta del servidor no es válida."

        case .unauthorized:
            return "La solicitud no está autorizada."

        case .forbidden:
            return "No tienes permisos para acceder al recurso."

        case .notFound:
            return "El recurso solicitado no fue encontrado."

        case .serverError:
            return "Ocurrió un error en el servidor."

        case .decodingError:
            return "No fue posible interpretar la respuesta."

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
