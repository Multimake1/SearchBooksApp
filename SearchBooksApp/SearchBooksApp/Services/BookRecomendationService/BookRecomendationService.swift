//
//  BookRecomendationService.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import Foundation

protocol IBookRecommendationService {
    func getRecommendations(for book: Book, completion: @escaping (Result<[Book], Error>) -> Void)
}

final class BookRecommendationService {
    private let searchBooksService: ISearchBooksService
    
    init(searchBooksService: ISearchBooksService = SearchBooksService()) {
        self.searchBooksService = searchBooksService
    }
    
    //определение темы поиска рекомндаций, рекомендуем по автору, если автора нет, то по названию
    private func determineSearchQuery(for book: Book) -> String {
        if let author = book.authorName?.first {
            return author
        } else if let title = book.title?.lowercased() {
            if title.contains("science") || title.contains("fiction") || title.contains("dune") || title.contains("foundation") {
                return "science fiction"
            } else if title.contains("harry") || title.contains("potter") || title.contains("fantasy") {
                return "fantasy"
            } else if title.contains("1984") || title.contains("orwell") || title.contains("classic") {
                return "classic literature"
            }
        }
        
        return "bestseller"
    }
}

extension BookRecommendationService: IBookRecommendationService {
    //получение рекомендации на основе книги, возвращаем первые 10
    func getRecommendations(for book: Book, completion: @escaping (Result<[Book], Error>) -> Void) {
        let searchQuery = determineSearchQuery(for: book)
        
        searchBooksService.searchBooks(query: searchQuery) { result in
            switch result {
            case .success(var books):
                books = books.filter { $0.key != book.key }
                let recommendations = Array(books.prefix(10))
                completion(.success(recommendations))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
