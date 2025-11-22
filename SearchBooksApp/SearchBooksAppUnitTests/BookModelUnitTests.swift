//
//  BookModelUnitTests.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
@testable import FinalProject

class BookTests: XCTestCase {
    
    func testWorkIdExtraction() {
        let book = Book(
            key: "/works/OL123W",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let workId = book.workId
        
        XCTAssertEqual(workId, "OL123W")
    }
    
    func testAuthorsText() {
        let bookWithAuthors = Book(
            key: "test1",
            title: "Test Book",
            authorName: ["Author 1", "Author 2"],
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithoutAuthors = Book(
            key: "test2",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        XCTAssertEqual(bookWithAuthors.authorsText, "Author 1, Author 2")
        XCTAssertEqual(bookWithoutAuthors.authorsText, "Unknown Author")
    }
    
    func testYearText() {
        let bookWithFirstYear = Book(
            key: "test1",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: 2020,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithPublishYears = Book(
            key: "test2",
            title: "Test Book",
            authorName: nil,
            publishYear: [2019, 2020],
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithoutYears = Book(
            key: "test3",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        XCTAssertEqual(bookWithFirstYear.yearText, "2020")
        XCTAssertEqual(bookWithPublishYears.yearText, "2019")
        XCTAssertEqual(bookWithoutYears.yearText, "Year unknown")
    }
    
    func testCoverURL() {
        let bookWithCover = Book(
            key: "test1",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: 123,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        let bookWithoutCover = Book(
            key: "test2",
            title: "Test Book",
            authorName: nil,
            publishYear: nil,
            isbn: nil,
            coverI: nil,
            firstPublishYear: nil,
            localCoverName: nil,
            description: nil
        )
        
        XCTAssertNotNil(bookWithCover.coverURL)
        XCTAssertNil(bookWithoutCover.coverURL)
    }
}

extension Book {
   static var mockBook: Book {
       return Book(
           key: "/works/OL123W",
           title: "Test Book",
           authorName: ["Test Author"],
           publishYear: [2020, 2021],
           isbn: ["1234567890"],
           coverI: 123,
           firstPublishYear: 2020,
           localCoverName: nil,
           description: "Test description"
       )
   }
   
   static var mockBookWithoutAuthor: Book {
       return Book(
           key: "test2",
           title: "Book Without Author",
           authorName: nil,
           publishYear: nil,
           isbn: nil,
           coverI: nil,
           firstPublishYear: nil,
           localCoverName: nil,
           description: nil
       )
   }
   
   static var mockBookWithWorkId: Book {
       return Book(
           key: "/works/OL456W",
           title: "Book With Work ID",
           authorName: ["Author One"],
           publishYear: [2019],
           isbn: ["0987654321"],
           coverI: 456,
           firstPublishYear: 2019,
           localCoverName: nil,
           description: "Another test description"
       )
   }
}
