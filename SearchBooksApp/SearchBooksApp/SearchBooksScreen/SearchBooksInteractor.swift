//
//  SearchBooksInteractor.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

protocol ISearchBooksInteractorInput: AnyObject {
    var presenter: ISearchBooksInteractorOutput? { get set }
    func searchBooks(query: String)
    func getCachedBooks(for query: String) -> [Book]?
    func clearAllCache()
    func clearSevenDaysCache()
}

protocol ISearchBooksInteractorOutput: AnyObject {
    func didSearchBooks(books: [Book])
    func onError(error: Error)
}

final class SearchBooksInteractor {
    weak var presenter: ISearchBooksInteractorOutput?
    private let searchBooksService: ISearchBooksService
    private let coreDataManager: ICoreDataManager
    
    init(
        searchBooksService: ISearchBooksService,
        coreDataManager: ICoreDataManager = CoreDataManager.shared
    ) {
        self.searchBooksService = searchBooksService
        self.coreDataManager = coreDataManager
    }
}

extension SearchBooksInteractor: ISearchBooksInteractorInput {
    //получение книг по текущему запросу, если нет в кэше, то создаем сетевой запрос
    func searchBooks(query: String) {
        if let cachedBooks = getCachedBooks(for: query), !cachedBooks.isEmpty {
            presenter?.didSearchBooks(books: cachedBooks)
            return
        }
        
        searchBooksService.searchBooks(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self?.coreDataManager.saveSearchQuery(query: query, books: books)
                    self?.presenter?.didSearchBooks(books: books)
                case .failure(let error):
                    self?.presenter?.onError(error: error)
                }
            }
        }
    }
    
    func clearSevenDaysCache() {
        coreDataManager.clearOldCache(olderThan: 7)
    }
    
    func clearAllCache() {
        coreDataManager.clearAllCache()
    }
    
    func getCachedBooks(for query: String) -> [Book]? {
        return coreDataManager.getCachedBooks(for: query)
    }
}
