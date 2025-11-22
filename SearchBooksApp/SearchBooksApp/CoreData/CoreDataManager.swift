//
//  CoreDataManager.swift
//  FinalProject
//
//  Created by Арсений on 19.11.2025.
//

import Foundation
import CoreData

protocol ICoreDataManager {
    func saveSearchQuery(query: String, books: [Book])
    func getCachedBooks(for query: String) -> [Book]?
    func clearOldCache(olderThan days: Int)
    func clearAllCache()
    func getCacheSize() -> Int
}

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        
    }
    
    //создание контейнера CoreData
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookSearch")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    //рабочая область для работы с данными
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //сохранение изменений
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataManager: ICoreDataManager {
    //сохранение результатов поиска по запросу в кэш
    func saveSearchQuery(query: String, books: [Book]) {
        let context = persistentContainer.viewContext
        
        deleteSearchQuery(query)
        
        let searchQuery = SearchQuery(context: context)
        searchQuery.query = query.lowercased()
        searchQuery.createdAt = Date()
        
        for book in books {
            let bookEntity = BookEntity(context: context)
            bookEntity.id = book.key
            bookEntity.title = book.title
            bookEntity.authorName = book.authorName?.joined(separator: ", ")
            bookEntity.coverId = Int32(book.coverI ?? 0)
            bookEntity.publishYear = book.publishYear?.map { String($0) }.joined(separator: ", ")
            bookEntity.isbn = book.isbn?.joined(separator: ", ")
            bookEntity.firstPublishYear = Int32(book.firstPublishYear ?? 0)
            bookEntity.bookDescription = book.description
            bookEntity.searchQuery = searchQuery
        }
        saveContext()
    }
    
    //получение закэшированных книг по запросу
    func getCachedBooks(for query: String) -> [Book]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "query == %@", query.lowercased())
        fetchRequest.fetchLimit = 1
        
        do {
            guard let searchQuery = try context.fetch(fetchRequest).first,
                  let bookEntities = searchQuery.books?.allObjects as? [BookEntity] else {
                return nil
            }
            
            return bookEntities.map { bookEntity in
                Book(
                    key: bookEntity.id ?? "",
                    title: bookEntity.title,
                    authorName: bookEntity.authorName?.components(separatedBy: ", "),
                    publishYear: bookEntity.publishYear?.components(separatedBy: ", ").compactMap { Int($0) },
                    isbn: bookEntity.isbn?.components(separatedBy: ", "),
                    coverI: Int(bookEntity.coverId),
                    firstPublishYear: Int(bookEntity.firstPublishYear),
                    localCoverName: bookEntity.localCoverName,
                    description: bookEntity.bookDescription
                )
            }
        } catch {
            print("Error fetching cached books: \(error)")
            return nil
        }
    }
    
    //удаление кэша по запросу
    private func deleteSearchQuery(_ query: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "query == %@", query.lowercased())
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Error deleting search query: \(error)")
        }
    }
    
    //очистка кэша больше 7 дней по всем запросам
    func clearOldCache(olderThan days: Int = 7) {
        let context = persistentContainer.viewContext
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createdAt < %@", expirationDate as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            saveContext()
            print("Cleared \(results.count) old cache entries")
        } catch {
            print("Error clearing old cache: \(error)")
        }
    }
    
    //очистка всего кэша по всем запросам
    func clearAllCache() {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            saveContext()
            print("Cleared all cache entries: \(results.count)")
        } catch {
            print("Error clearing all cache: \(error)")
        }
    }
    
    //получение размера кэша
    func getCacheSize() -> Int {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.count
        } catch {
            print("Error getting cache size: \(error)")
            return 0
        }
    }
}
