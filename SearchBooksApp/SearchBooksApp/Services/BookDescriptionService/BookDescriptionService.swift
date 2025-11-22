//
//  BookDescriptionService.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import Foundation

protocol IBookDescriptionService {
    func fetchBookDescription(workId: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class BookDescriptionService {
    private let baseURL = "https://openlibrary.org"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    //извлечение описания книги из json
    private func extractDescription(from json: [String: Any]) -> String {
        if let description = json["description"] as? String {
            return description
        } else if let descriptionDict = json["description"] as? [String: Any],
                  let value = descriptionDict["value"] as? String {
            return value
        } else if let firstSentence = json["first_sentence"] as? [String: Any],
                  let value = firstSentence["value"] as? String {
            return "Первое предложение: \(value)"
        }
        
        return "Описание отсутствует"
    }
}

extension BookDescriptionService: IBookDescriptionService {
    //сетевой запрос по айди работы
    func fetchBookDescription(workId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/works/\(workId).json") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let description = self.extractDescription(from: json)
                    completion(.success(description))
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
