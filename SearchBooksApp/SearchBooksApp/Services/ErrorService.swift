//
//  ErrorService.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case rateLimitExceeded
    case serverError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .decodingError:
            return "Error processing data"
        }
    }
}
