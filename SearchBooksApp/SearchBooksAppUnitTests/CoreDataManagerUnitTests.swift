//
//  FinalProjectUnitTests.swift
//  FinalProjectUnitTests
//
//  Created by Арсений on 22.11.2025.
//

import XCTest
import CoreData
@testable import FinalProject

class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
        setupMockCoreDataStack()
    }
    
    override func tearDown() {
        coreDataManager.clearAllCache()
        super.tearDown()
    }
    
    private func setupMockCoreDataStack() {
        let container = NSPersistentContainer(name: "BookSearch")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            XCTAssertNil(error)
        }
        
        coreDataManager.persistentContainer = container
    }
    
    func testSaveAndRetrieveSearchQuery() {
        let query = "test query"
        let books = [
            Book(
                key: "test1",
                title: "Test Book 1",
                authorName: ["Author 1"],
                publishYear: [2020],
                isbn: ["123456"],
                coverI: 123,
                firstPublishYear: 2020,
                localCoverName: nil,
                description: "Test description 1"
            )
        ]
        
        coreDataManager.saveSearchQuery(query: query, books: books)
        let retrievedBooks = coreDataManager.getCachedBooks(for: query)
        
        XCTAssertNotNil(retrievedBooks)
        XCTAssertEqual(retrievedBooks?.count, 1)
        XCTAssertEqual(retrievedBooks?.first?.title, "Test Book 1")
        XCTAssertEqual(retrievedBooks?.first?.authorName?.first, "Author 1")
    }
    
    func testGetCachedBooksForNonExistentQuery() {
        let books = coreDataManager.getCachedBooks(for: "non-existent")
        
        XCTAssertNil(books)
    }
    
    func testClearOldCache() {
        let query = "test query"
        let books = [Book(key: "test1", title: "Test Book", authorName: nil, publishYear: nil, isbn: nil, coverI: nil, firstPublishYear: nil, localCoverName: nil, description: nil)]
        
        coreDataManager.saveSearchQuery(query: query, books: books)
        let initialSize = coreDataManager.getCacheSize()
        
        coreDataManager.clearOldCache(olderThan: -1)
        
        let finalSize = coreDataManager.getCacheSize()
        
        XCTAssertEqual(initialSize, 1)
        XCTAssertEqual(finalSize, 0)
    }
    
    func testClearAllCache() {
        let books = [Book(key: "test1", title: "Test Book", authorName: nil, publishYear: nil, isbn: nil, coverI: nil, firstPublishYear: nil, localCoverName: nil, description: nil)]
        
        coreDataManager.saveSearchQuery(query: "query1", books: books)
        coreDataManager.saveSearchQuery(query: "query2", books: books)
        
        let initialSize = coreDataManager.getCacheSize()
        coreDataManager.clearAllCache()
        let finalSize = coreDataManager.getCacheSize()
        
        XCTAssertEqual(initialSize, 2)
        XCTAssertEqual(finalSize, 0)
    }
    
    func testCacheSize() {
        let books = [Book(key: "test1", title: "Test Book", authorName: nil, publishYear: nil, isbn: nil, coverI: nil, firstPublishYear: nil, localCoverName: nil, description: nil)]
        
        coreDataManager.saveSearchQuery(query: "query1", books: books)
        coreDataManager.saveSearchQuery(query: "query2", books: books)
        let size = coreDataManager.getCacheSize()
        
        XCTAssertEqual(size, 2)
    }
    
    func testDuplicateQueryOverwrites() {
        let query = "duplicate query"
        let firstBooks = [
            Book(key: "first", title: "First Book", authorName: nil, publishYear: nil, isbn: nil, coverI: nil, firstPublishYear: nil, localCoverName: nil, description: nil)
        ]
        
        let secondBooks = [
            Book(key: "second", title: "Second Book", authorName: nil, publishYear: nil, isbn: nil, coverI: nil, firstPublishYear: nil, localCoverName: nil, description: nil)
        ]
        
        coreDataManager.saveSearchQuery(query: query, books: firstBooks)
        coreDataManager.saveSearchQuery(query: query, books: secondBooks)
        let retrievedBooks = coreDataManager.getCachedBooks(for: query)
        
        XCTAssertEqual(retrievedBooks?.count, 1)
        XCTAssertEqual(retrievedBooks?.first?.title, "Second Book")
    }
}
