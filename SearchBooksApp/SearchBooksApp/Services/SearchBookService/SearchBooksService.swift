//
//  APIService.swift
//  FinalProject
//
//  Created by Арсений on 19.11.2025.
//

import Foundation

protocol ISearchBooksService {
    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void)
}

final class SearchBooksService {
    private let baseURL = "https://openlibrary.org/search.json"
    private let backupBaseURL = "https://corsproxy.io/?https://openlibrary.org/search.json"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    private func makeURL(for query: String, useBackup: Bool = false) -> URL? {
        let base = useBackup ? backupBaseURL : baseURL
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "\(base)?q=\(encodedQuery)&limit=20")
    }
}

extension SearchBooksService: ISearchBooksService {
    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(encodedQuery)&limit=20") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                break
            case 429:
                completion(.failure(NetworkError.rateLimitExceeded))
                return
            case 500...599:
                completion(.failure(NetworkError.serverError))
                return
            default:
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            if data.isEmpty {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(BookSearchResponse.self, from: data)
                completion(.success(searchResponse.docs))
            } catch let decodingError as DecodingError {
                completion(.failure(NetworkError.decodingError))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }
        task.resume()
    }
}


