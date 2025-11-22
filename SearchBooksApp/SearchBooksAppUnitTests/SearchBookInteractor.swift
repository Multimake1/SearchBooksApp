//
//  SearchBookInteractor.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
@testable import FinalProject

class SearchBooksInteractorTests: XCTestCase {
    
    var interactor: SearchBooksInteractor!
    var mockSearchService: MockSearchBooksService!
    var mockCoreDataManager: MockCoreDataManager!
    var mockPresenter: MockSearchBooksInteractorOutput!
    
    override func setUp() {
        super.setUp()
        mockSearchService = MockSearchBooksService()
        mockCoreDataManager = MockCoreDataManager()
        mockPresenter = MockSearchBooksInteractorOutput()
        
        interactor = SearchBooksInteractor(
            searchBooksService: mockSearchService,
            coreDataManager: mockCoreDataManager
        )
        interactor.presenter = mockPresenter
    }
    
    override func tearDown() {
        interactor = nil
        mockSearchService = nil
        mockCoreDataManager = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    func testSearchBooksWithCache() {
        let query = "cached query"
        let cachedBooks = [
            Book(
                key: "cached1",
                title: "Cached Book",
                authorName: nil,
                publishYear: nil,
                isbn: nil,
                coverI: nil,
                firstPublishYear: nil,
                localCoverName: nil,
                description: nil
            )
        ]
        mockCoreDataManager.cachedBooks = cachedBooks
        
        interactor.searchBooks(query: query)
        
        XCTAssertTrue(mockPresenter.didSearchBooksCalled)
        XCTAssertEqual(mockPresenter.receivedBooks?.count, 1)
        XCTAssertEqual(mockPresenter.receivedBooks?.first?.title, "Cached Book")
        XCTAssertFalse(mockSearchService.searchBooksCalled)
    }
    
    func testSearchBooksWithoutCache() {
        let query = "new query"
        let serviceBooks = [
            Book(
                key: "service1",
                title: "Service Book",
                authorName: nil,
                publishYear: nil,
                isbn: nil,
                coverI: nil,
                firstPublishYear: nil,
                localCoverName: nil,
                description: nil
            )
        ]
        mockCoreDataManager.cachedBooks = nil
        mockSearchService.mockResult = .success(serviceBooks)
        
        let expectation = self.expectation(description: "Search completion")
        mockPresenter.asyncExpectation = expectation
        
        interactor.searchBooks(query: query)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockSearchService.searchBooksCalled)
            XCTAssertTrue(self.mockPresenter.didSearchBooksCalled)
            XCTAssertEqual(self.mockPresenter.receivedBooks?.count, 1)
            XCTAssertEqual(self.mockPresenter.receivedBooks?.first?.title, "Service Book")
        }
    }
    
    func testSearchBooksWithError() {
        let query = "error query"
        mockCoreDataManager.cachedBooks = nil
        mockSearchService.mockResult = .failure(NetworkError.serverError)
        
        let expectation = self.expectation(description: "Error completion")
        mockPresenter.asyncExpectation = expectation
        
        interactor.searchBooks(query: query)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockSearchService.searchBooksCalled)
            XCTAssertTrue(self.mockPresenter.onErrorCalled)
            XCTAssertNotNil(self.mockPresenter.receivedError)
        }
    }
    
    func testClearSevenDaysCache() {
        interactor.clearSevenDaysCache()
        
        XCTAssertTrue(mockCoreDataManager.clearOldCacheCalled)
    }
    
    func testClearAllCache() {
        interactor.clearAllCache()
        
        XCTAssertTrue(mockCoreDataManager.clearAllCacheCalled)
    }
    
    func testGetCachedBooks() {
        let query = "test query"
        let expectedBooks = [
            Book(
                key: "test1",
                title: "Test Book",
                authorName: nil,
                publishYear: nil,
                isbn: nil,
                coverI: nil,
                firstPublishYear: nil,
                localCoverName: nil,
                description: nil
            )
        ]
        mockCoreDataManager.cachedBooks = expectedBooks
        
        let result = interactor.getCachedBooks(for: query)
        
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.title, "Test Book")
    }
}

class MockSearchBooksService: ISearchBooksService {
    var searchBooksCalled = false
    var lastQuery: String?
    var mockResult: Result<[Book], Error>?
    
    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        searchBooksCalled = true
        lastQuery = query
        
        DispatchQueue.global().async {
            if let result = self.mockResult {
                completion(result)
            }
        }
    }
}

class MockCoreDataManager: ICoreDataManager {
    var cachedBooks: [Book]?
    var saveCalled = false
    var clearOldCacheCalled = false
    var clearAllCacheCalled = false
    var lastSavedQuery: String?
    var lastSavedBooks: [Book]?
    
    func saveSearchQuery(query: String, books: [Book]) {
        saveCalled = true
        lastSavedQuery = query
        lastSavedBooks = books
        cachedBooks = books
    }
    
    func getCachedBooks(for query: String) -> [Book]? {
        return cachedBooks
    }
    
    func clearOldCache(olderThan days: Int) {
        clearOldCacheCalled = true
        cachedBooks = nil
    }
    
    func clearAllCache() {
        clearAllCacheCalled = true
        cachedBooks = nil
    }
    
    func getCacheSize() -> Int {
        return cachedBooks?.count ?? 0
    }
}

class MockSearchBooksInteractorOutput: ISearchBooksInteractorOutput {
    var didSearchBooksCalled = false
    var onErrorCalled = false
    var receivedBooks: [Book]?
    var receivedError: Error?
    var asyncExpectation: XCTestExpectation?
    
    func didSearchBooks(books: [Book]) {
        didSearchBooksCalled = true
        receivedBooks = books
        asyncExpectation?.fulfill()
    }
    
    func onError(error: Error) {
        onErrorCalled = true
        receivedError = error
        asyncExpectation?.fulfill()
    }
}
