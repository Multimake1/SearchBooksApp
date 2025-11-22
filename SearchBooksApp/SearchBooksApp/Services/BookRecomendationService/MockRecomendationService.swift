//
//  MockRecomendationService.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import Foundation

final class MockBookRecommendationService: IBookRecommendationService {
    func getRecommendations(for book: Book, completion: @escaping (Result<[Book], Error>) -> Void) {
        let mockRecommendations = [
            Book(
                key: "/works/OL8W",
                title: "Dune Messiah",
                authorName: ["Frank Herbert"],
                publishYear: [1969],
                isbn: ["9780441102679"],
                coverI: -8,
                firstPublishYear: 1969,
                localCoverName: "107",
                description: "Продолжение саги о Дюне, вторая книга цикла."
            ),
            Book(
                key: "/works/OL9W",
                title: "Children of Dune",
                authorName: ["Frank Herbert"],
                publishYear: [1976],
                isbn: ["9780441102686"],
                coverI: -9,
                firstPublishYear: 1976,
                localCoverName: "108",
                description: "Третья книга цикла Дюна, продолжение истории семьи Атрейдес."
            ),
            Book(
                key: "/works/OL10W",
                title: "The Left Hand of Darkness",
                authorName: ["Ursula K. Le Guin"],
                publishYear: [1969],
                isbn: ["9780441478125"],
                coverI: -10,
                firstPublishYear: 1969,
                localCoverName: "109",
                description: "Классика научной фантастики о гендерных отношениях."
            )
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(mockRecommendations))
        }
    }
}
