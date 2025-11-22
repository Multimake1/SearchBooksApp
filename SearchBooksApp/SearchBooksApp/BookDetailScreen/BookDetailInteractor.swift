//
//  BookDetailInteractor.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

protocol IBookDetailInteractorInput: AnyObject {
    var presenter: IBookDetailInteractorOutput? { get set }
    func loadBookDescription(book: Book)
    func loadBookRecommendations(book: Book)
}

protocol IBookDetailInteractorOutput: AnyObject {
    func didLoadDescription(description: String)
    func didFailLoadingDescription(error: Error)
    func didLoadRecommendations(books: [Book])
    func didFailLoadingRecommendations(error: Error)
}

final class BookDetailInteractor {
    weak var presenter: IBookDetailInteractorOutput?
    private let bookDescriptionService: IBookDescriptionService
    private let bookRecommendationService: IBookRecommendationService
    
    init(
        bookDescriptionService: IBookDescriptionService,
        bookRecommendationService: IBookRecommendationService
    ) {
        self.bookDescriptionService = bookDescriptionService
        self.bookRecommendationService = bookRecommendationService
    }
}

extension BookDetailInteractor: IBookDetailInteractorInput {
    //загрузка описания книги
    func loadBookDescription(book: Book) {
        guard let workId = book.workId else {
            let error = NSError(domain: "BookDetail", code: 0, userInfo: [NSLocalizedDescriptionKey: "No work ID available"])
            presenter?.didFailLoadingDescription(error: error)
            return
        }
        
        bookDescriptionService.fetchBookDescription(workId: workId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let description):
                    self?.presenter?.didLoadDescription(description: description)
                case .failure(let error):
                    self?.presenter?.didFailLoadingDescription(error: error)
                }
            }
        }
    }
    
    //загрузка рекомендаций
    func loadBookRecommendations(book: Book) {
        bookRecommendationService.getRecommendations(for: book) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recommendations):
                    self?.presenter?.didLoadRecommendations(books: recommendations)
                case .failure(let error):
                    self?.presenter?.didFailLoadingRecommendations(error: error)
                }
            }
        }
    }
}
