//
//  SearchBooksPresenter.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

protocol ISearchBooksPresenter: AnyObject {
    func loadView(view: ISearchBooksView)
    func loadInitialBooks()
    func searchBooks(query: String)
    func didSelectBook(book: Book)
    func numberOfBooks() -> Int
    func book(at index: Int) -> Book?
    func isBookFromCache(at index: Int) -> Bool
    func clearAllCache()
    func clearSevenDaysCache()
}

final class SearchBooksPresenter {
    private weak var view: ISearchBooksView?
    private var interactor: ISearchBooksInteractorInput
    private var router: ISearchBooksRouter?
    
    private var books: [Book] = []
    private var isCurrentResultFromCache: Bool = false
    
    struct Dependencies {
        let router: ISearchBooksRouter
        let interactor: ISearchBooksInteractorInput
    }
    
    init(dependecies: Dependencies) {
        self.router = dependecies.router
        self.interactor = dependecies.interactor
        self.interactor.presenter = self
    }
}

extension SearchBooksPresenter: ISearchBooksPresenter {
    func loadView(view: ISearchBooksView) {
        self.view = view
    }
    
    //всегда делается запрос для начальной загрузки
    func loadInitialBooks() {
        view?.showLoading()
        let initialQuery = "popular books"
        self.isCurrentResultFromCache = false
        interactor.searchBooks(query: initialQuery)
    }
    
    func searchBooks(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedQuery.isEmpty else {
            books = []
            view?.showInitialState()
            return
        }
        
        view?.showLoading()
        
        if let cachedBooks = interactor.getCachedBooks(for: trimmedQuery), !cachedBooks.isEmpty {
            self.books = cachedBooks
            self.isCurrentResultFromCache = true
            view?.hideLoading()
            view?.showBooks(books: cachedBooks)
        } else {
            self.isCurrentResultFromCache = false
            interactor.searchBooks(query: trimmedQuery)
        }
    }
    
    func didSelectBook(book: Book) {
        router?.showBooksDetailHandler(with: book)
    }
    
    func numberOfBooks() -> Int {
        return books.count
    }
    
    func book(at index: Int) -> Book? {
        guard index >= 0 && index < books.count else { return nil }
        return books[index]
    }
    
    func isBookFromCache(at index: Int) -> Bool {
        return isCurrentResultFromCache
    }
    
    func clearAllCache() {
        self.interactor.clearAllCache()
    }
    
    func clearSevenDaysCache() {
        self.interactor.clearSevenDaysCache()
    }
}

extension SearchBooksPresenter: ISearchBooksInteractorOutput {
    func didSearchBooks(books: [Book]) {
        self.books = books
        view?.hideLoading()
        
        if books.isEmpty {
            view?.showEmptyState()
        } else {
            view?.showBooks(books: books)
        }
    }
    
    func onError(error: Error) {
        view?.hideLoading()
        view?.showError(error: error.localizedDescription)
    }
}
