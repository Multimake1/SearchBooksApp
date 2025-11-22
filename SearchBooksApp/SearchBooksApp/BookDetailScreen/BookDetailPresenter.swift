//
//  BookDetailPresenter.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

protocol IBookDetailPresenter: AnyObject {
    func updateUI()
    func didTapGet()
    func didTapClose()
    func loadView(view: IBookDetailView)
    func loadBookDescriptionIfNeeded()
    func didSelectRecommendedBook(book: Book)
}

final class BookDetailPresenter {
    private let router: IBookDetailRouter
    private let book: Book
    private let interactor: IBookDetailInteractorInput
    private weak var view: IBookDetailView?
    private var recommendedBooks: [Book] = []
    
    struct Dependencies {
        let router: IBookDetailRouter
        let book: Book
        let interactor: IBookDetailInteractorInput
    }
    
    init(dependecies: Dependencies) {
        self.router = dependecies.router
        self.book = dependecies.book
        self.interactor = dependecies.interactor
        
        self.interactor.presenter = self
    }
}

extension BookDetailPresenter: IBookDetailPresenter {
    func loadView(view: IBookDetailView) {
        self.view = view
        self.updateUI()
        self.loadBookDescriptionIfNeeded()
        self.loadBookRecommendations()
        
        view.onGetBookButtonTapped = { [weak self] in
            self?.didTapGet()
        }
                
        view.onCloseButtonTapped = { [weak self] in
            self?.didTapClose()
        }
        
        view.onRecommendedBookSelected = { [weak self] book in
            self?.didSelectRecommendedBook(book: book)
        }
    }
    
    func updateUI() {
        view?.displayBookDetails(book: book)
    }
    
    func didTapGet() {
        router.showBookGetHandler(with: book)
    }
    
    func didTapClose() {
        router.dismissHandler()
    }
    
    func loadBookDescriptionIfNeeded() {
        if book.description != nil {
            return
        }
        self.interactor.loadBookDescription(book: book)
    }
    
    private func loadBookRecommendations() {
        self.interactor.loadBookRecommendations(book: book)
    }
    
    func didSelectRecommendedBook(book: Book) {
        router.showRecommendedBookDetailHandler(with: book)
    }
}

extension BookDetailPresenter: IBookDetailInteractorOutput {
    func didLoadDescription(description: String) {
        self.view?.updateDescription(description: description)
    }
    
    func didFailLoadingDescription(error: Error) {
        self.view?.updateDescription(description: "Не удалось загрузить описание: \(error.localizedDescription)")
    }
    
    func didLoadRecommendations(books: [Book]) {
        self.recommendedBooks = books
        self.view?.displayRecommendedBooks(books: books)
    }
        
    func didFailLoadingRecommendations(error: Error) {
        self.view?.displayRecommendedBooks(books: [])
    }
}
