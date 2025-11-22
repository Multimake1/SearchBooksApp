//
//  Book.swift
//  FinalProject
//
//  Created by Арсений on 19.11.2025.
//

import UIKit

struct BookSearchResponse: Codable {
    let numFound: Int           //количество найденных книг
    let start: Int              //позиция первой книги в выборке(для пагинации)
    let docs: [Book]            //массив найденных книг
    
    enum CodingKeys: String, CodingKey {
        case docs
        case numFound = "num_found"
        case start
    }
}

struct Book: Codable {
    let key: String?            //id
    let title: String?          //название книги
    let authorName: [String]?   //имена авторов
    let publishYear: [Int]?     //массив годов разных публикаций
    let isbn: [String]?         //уникальный идетификационный номер книги
    let coverI: Int?            //id обложки в Open Library Covers API
    let firstPublishYear: Int?  //год первой публикации
    let localCoverName: String? //картинки для моковых данных
    let description: String?    //описание книги
    
    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName = "author_name"
        case publishYear = "publish_year"
        case isbn
        case coverI = "cover_i"
        case firstPublishYear = "first_publish_year"
        case localCoverName
        case description
    }
    
    //для описания книги из ключа "/works/OL123W" получаем "OL123W"
    var workId: String? {
        guard let key = key else { return nil }
        
        if key.contains("/works/") {
            return key.components(separatedBy: "/").last
        } else if key.hasPrefix("OL") && key.hasSuffix("W") {
            return key
        }
        
        return nil
    }
    
    //объединение авторов в строку
    var authorsText: String {
        return authorName?.joined(separator: ", ") ?? "Unknown Author"
    }
    
    //поиск года первой публикации, если их несколько берем первый
    var yearText: String {
        if let firstYear = firstPublishYear {
            return "\(firstYear)"
        } else if let years = publishYear, let firstYear = years.first {
            return "\(firstYear)"
        }
        return "Year unknown"
    }
    
    //создание url для загрузки обложки
    var coverURL: URL? {
        if localCoverName != nil {
            return nil
        }
        guard let coverId = coverI, coverId > 0 else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverId)-M.jpg")
    }
    
    //загрузка изображения из ассетов
    var localCoverImage: UIImage? {
        guard let localCoverName = localCoverName else { return nil }
        return UIImage(named: localCoverName)
    }
    
    //проверка на локальную обложку
    var hasLocalCover: Bool {
        return localCoverName != nil
    }
    
    //проверка на существование описания
    var formattedDescription: String {
        return description ?? "Описание отсутствует"
    }
    
    //проверка на то, что книга рабочая
    var isWork: Bool {
        return workId != nil
    }
}
