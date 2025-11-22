//
//  SmartSearchBookService.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

//сервис для загрузки позволяющий мокать данные если с настоящими случилась какая-то ошибка
final class SmartSearchBooksService: ISearchBooksService {
    private let realService: ISearchBooksService
    private let mockService: ISearchBooksService
    private var isRealAPIDown = false
    
    init(realService: ISearchBooksService = SearchBooksService(),
         mockService: ISearchBooksService = RobustMockSearchBooksService()) {
        self.realService = realService
        self.mockService = mockService
    }
    
    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        if isRealAPIDown {
            mockService.searchBooks(query: query, completion: completion)
            return
        }
        
        realService.searchBooks(query: query) { [weak self] result in
            switch result {
            case .success(let books):
                completion(.success(books))
            case .failure(let error):
                self?.isRealAPIDown = true
                self?.mockService.searchBooks(query: query, completion: completion)
            }
        }
    }
}
