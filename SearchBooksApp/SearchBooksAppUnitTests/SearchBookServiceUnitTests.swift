//
//  SearchBookServiceUnitTests.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
@testable import FinalProject

class SearchBooksServiceTests: XCTestCase {
    
    var searchService: SearchBooksService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        self.mockURLSession = MockURLSession()
        self.searchService = SearchBooksService(urlSession: self.mockURLSession)
    }
    
    override func tearDown() {
        self.searchService = nil
        self.mockURLSession = nil
        super.tearDown()
    }
    
    func testSearchBooksSuccess() {
        let query = "test"
        let expectedBooks = [
            Book(
                key: "/works/OL123W",
                title: "Test Book",
                authorName: ["Test Author"],
                publishYear: [2020],
                isbn: ["1234567890"],
                coverI: 123,
                firstPublishYear: 2020,
                localCoverName: nil,
                description: "Test description"
            )
        ]
        
        let response = BookSearchResponse(
            numFound: 1,
            start: 0,
            docs: expectedBooks
        )
        
        let jsonData = try! JSONEncoder().encode(response)
        self.mockURLSession.data = jsonData
        self.mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedBooks: [Book]?
        self.searchService.searchBooks(query: query) { result in
            if case .success(let books) = result {
                receivedBooks = books
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedBooks?.count, 1)
        XCTAssertEqual(receivedBooks?.first?.title, "Test Book")
    }
    
    func testSearchBooksRateLimit() {
        let query = "test"
        self.mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result, let networkError = error as? NetworkError {
                receivedError = networkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .rateLimitExceeded)
    }
    
    func testSearchBooksInvalidURL() {
        let query = ""
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result, let networkError = error as? NetworkError {
                receivedError = networkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .invalidURL)
    }
    
    func testSearchBooksServerError() {
        let query = "test"
        self.mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result, let networkError = error as? NetworkError {
                receivedError = networkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .serverError)
    }
    
    func testSearchBooksInvalidResponse() {
        let query = "test"
        self.mockURLSession.response = URLResponse(
            url: URL(string: "https://test.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result, let networkError = error as? NetworkError {
                receivedError = networkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .invalidResponse)
    }
    
    func testSearchBooksInvalidData() {
        let query = "test"
        self.mockURLSession.data = Data()
        self.mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result, let networkError = error as? NetworkError {
                receivedError = networkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .invalidData)
    }
    
    func testSearchBooksDecodingError() {
        let query = "test"
        
        let invalidJSON = """
        {
            "invalid": "json",
            "num_found": "not_a_number",  // Должно быть число
            "start": "also_not_number",   // Должно быть число
            "docs": "should_be_array"     // Должен быть массив
        }
        """.data(using: .utf8)
        
        self.mockURLSession.data = invalidJSON
        self.mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Search completion")
        
        var receivedError: NetworkError?
        self.searchService.searchBooks(query: query) { result in
            if case .failure(let error) = result {
                receivedError = error as? NetworkError
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, .decodingError, "Should return decodingError for invalid JSON")
    }
}

class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, self.response, self.error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
