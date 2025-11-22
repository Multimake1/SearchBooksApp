//
//  BookDetailInteractorTests.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
@testable import FinalProject

class BookDetailInteractorTests: XCTestCase {
    
    var interactor: BookDetailInteractor!
    var mockDescriptionService: MockBookDescriptionService!
    var mockRecommendationService: MockBookRecommendationService!
    var mockPresenter: MockBookDetailInteractorOutput!
    
    override func setUp() {
        super.setUp()
        mockDescriptionService = MockBookDescriptionService()
        mockRecommendationService = MockBookRecommendationService()
        mockPresenter = MockBookDetailInteractorOutput()
        
        interactor = BookDetailInteractor(
            bookDescriptionService: mockDescriptionService,
            bookRecommendationService: mockRecommendationService
        )
        interactor.presenter = mockPresenter
    }
    
    func testLoadBookDescriptionSuccess() {
        let book = Book.mockBook
        mockDescriptionService.mockResult = .success("Test description")
        
        let expectation = self.expectation(description: "Description loaded")
        mockPresenter.asyncExpectation = expectation
        
        interactor.loadBookDescription(book: book)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockPresenter.didLoadDescriptionCalled)
            XCTAssertEqual(self.mockPresenter.receivedDescription, "Test description")
        }
    }
    
    func testLoadBookDescriptionWithoutWorkId() {
        let book = Book(
            key: "invalid_key",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        interactor.loadBookDescription(book: book)
        
        XCTAssertTrue(mockPresenter.didFailLoadingDescriptionCalled)
        XCTAssertNotNil(mockPresenter.receivedError)
    }
    
    func testLoadBookDescriptionWithError() {
        let book = Book.mockBook
        mockDescriptionService.mockResult = .failure(NetworkError.serverError)
        
        let expectation = self.expectation(description: "Description error")
        mockPresenter.asyncExpectation = expectation
        
        interactor.loadBookDescription(book: book)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockPresenter.didFailLoadingDescriptionCalled)
            XCTAssertNotNil(self.mockPresenter.receivedError)
        }
    }
    
    func testLoadBookRecommendations() {
        let book = Book.mockBook
        let recommendations = [Book.mockBook]
        mockRecommendationService.mockResult = .success(recommendations)
        
        let expectation = self.expectation(description: "Recommendations loaded")
        mockPresenter.asyncExpectation = expectation
        
        interactor.loadBookRecommendations(book: book)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockPresenter.didLoadRecommendationsCalled)
            XCTAssertEqual(self.mockPresenter.receivedRecommendations?.count, 1)
        }
    }
}

class MockBookDescriptionService: IBookDescriptionService {
    var mockResult: Result<String, Error>?
    var lastWorkId: String?
    
    func fetchBookDescription(workId: String, completion: @escaping (Result<String, Error>) -> Void) {
        lastWorkId = workId
        
        DispatchQueue.global().async {
            if let result = self.mockResult {
                completion(result)
            }
        }
    }
}

class MockBookRecommendationService: IBookRecommendationService {
    var mockResult: Result<[Book], Error>?
    var lastBook: Book?
    
    func getRecommendations(for book: Book, completion: @escaping (Result<[Book], Error>) -> Void) {
        lastBook = book
        
        DispatchQueue.global().async {
            if let result = self.mockResult {
                completion(result)
            }
        }
    }
}

class MockBookDetailInteractorOutput: IBookDetailInteractorOutput {
    var didLoadDescriptionCalled = false
    var didFailLoadingDescriptionCalled = false
    var didLoadRecommendationsCalled = false
    var didFailLoadingRecommendationsCalled = false
    
    var receivedDescription: String?
    var receivedRecommendations: [Book]?
    var receivedError: Error?
    var asyncExpectation: XCTestExpectation?
    
    func didLoadDescription(description: String) {
        didLoadDescriptionCalled = true
        receivedDescription = description
        asyncExpectation?.fulfill()
    }
    
    func didFailLoadingDescription(error: Error) {
        didFailLoadingDescriptionCalled = true
        receivedError = error
        asyncExpectation?.fulfill()
    }
    
    func didLoadRecommendations(books: [Book]) {
        didLoadRecommendationsCalled = true
        receivedRecommendations = books
        asyncExpectation?.fulfill()
    }
    
    func didFailLoadingRecommendations(error: Error) {
        didFailLoadingRecommendationsCalled = true
        receivedError = error
        asyncExpectation?.fulfill()
    }
}
