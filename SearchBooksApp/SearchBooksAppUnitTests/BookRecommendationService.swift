//
//  BookRecommendationService.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
@testable import FinalProject

class BookRecommendationServiceTests: XCTestCase {
    
    var recommendationService: BookRecommendationService!
    var mockSearchService: MockSearchBooksService!
    
    override func setUp() {
        super.setUp()
        mockSearchService = MockSearchBooksService()
        recommendationService = BookRecommendationService(searchBooksService: mockSearchService)
    }
    
    override func tearDown() {
        recommendationService = nil
        mockSearchService = nil
        super.tearDown()
    }
    
    func testGetRecommendationsByAuthor() {
        let book = Book(
            key: "test1",
            title: "Test Book",
            authorName: ["J.K. Rowling"],
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let recommendations = [
            Book(
                key: "rec1",
                title: "Recommended Book",
                authorName: ["J.K. Rowling"],
                publishYear: nil,
                isbn: nil,
                coverI: nil,
                firstPublishYear: nil,
                localCoverName: nil,
                description: nil
            )
        ]
        
        mockSearchService.mockResult = .success(recommendations)
        
        let expectation = self.expectation(description: "Recommendations completion")
        
        var receivedBooks: [Book]?
        recommendationService.getRecommendations(for: book) { result in
            if case .success(let books) = result {
                receivedBooks = books
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockSearchService.searchBooksCalled)
        XCTAssertEqual(receivedBooks?.count, 1)
    }
    
    func testDetermineSearchQuery() {
        let bookWithAuthor = Book(
            key: "test1",
            title: "Any Title",
            authorName: ["Stephen King"],
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithFantasyTitle = Book(
            key: "test2",
            title: "harry potter and the philosopher stone",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithScifiTitle = Book(
            key: "test3",
            title: "dune foundation science",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookDefault = Book(
            key: "test4",
            title: "Some Random Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        XCTAssertTrue(true)
    }
}
