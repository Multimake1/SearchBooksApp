//
//  MockAPIService.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import Foundation

final class RobustMockSearchBooksService: ISearchBooksService {
    func searchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        let mockBooks: [Book]
        
        switch query.lowercased() {
        case "science", "science fiction":
            mockBooks = [
                Book(
                    key: "/works/OL1W",
                    title: "Dune",
                    authorName: ["Frank Herbert"],
                    publishYear: [1965],
                    isbn: ["9780441013593"],
                    coverI: -1,
                    firstPublishYear: 1965,
                    localCoverName: "100",
                    description: "«Дюна» — научно-фантастический роман Фрэнка Герберта, рассказывающий историю Пола Атрейдеса, чья семья принимает управление опасной пустынной планетой Арракис. Единственный источник самой ценной субстанции во вселенной — «пряности» — может быть найден только на Дюне."
                ),
                Book(
                    key: "/works/OL2W",
                    title: "Foundation",
                    authorName: ["Isaac Asimov"],
                    publishYear: [1951],
                    isbn: ["9780553293357"],
                    coverI: -2,
                    firstPublishYear: 1951,
                    localCoverName: "101",
                    description: "«Основание» — научно-фантастический роман Айзека Азимова, первый из цикла «Основание». Сюжет вращается вокруг падения Галактической Империи и попыток группы ученых сохранить знание и сократить период хаоса с 30 000 до 1000 лет."
                ),
                Book(
                    key: "/works/OL3W",
                    title: "Neuromancer",
                    authorName: ["William Gibson"],
                    publishYear: [1984],
                    isbn: ["9780441569595"],
                    coverI: -3,
                    firstPublishYear: 1984,
                    localCoverName: "102",
                    description: "Роман Уильяма Гибсона, который положил начало жанру киберпанк. История хакера Кейса, нанятого для совершения последнего крупного взлома в киберпространстве."
                )
            ]
        case "harry potter":
            mockBooks = [
                Book(
                    key: "/works/OL4W",
                    title: "Harry Potter and the Philosopher's Stone",
                    authorName: ["J.K. Rowling"],
                    publishYear: [1997],
                    isbn: ["9780747532699"],
                    coverI: -4,
                    firstPublishYear: 1997,
                    localCoverName: "103",
                    description: "Первая книга в серии о Гарри Поттере, рассказывающая историю мальчика-сироты, который на свой одиннадцатый день рождения discovers, что он является волшебником и зачислен в школу магии и волшебства Хогвартс."
                )
            ]
        case "classic":
            mockBooks = [
                Book(
                    key: "/works/OL5W",
                    title: "1984",
                    authorName: ["George Orwell"],
                    publishYear: [1949],
                    isbn: ["9780451524935"],
                    coverI: -5,
                    firstPublishYear: 1949,
                    localCoverName: "104",
                    description: "Антиутопический роман-предупреждение Джорджа Оруэлла о тоталитарном обществе, где правительство осуществляет тотальный контроль над каждым аспектом человеческой жизни, включая мысли и чувства."
                ),
                Book(
                    key: "/works/OL6W",
                    title: "To Kill a Mockingbird",
                    authorName: ["Harper Lee"],
                    publishYear: [1960],
                    isbn: ["9780061120084"],
                    coverI: -6,
                    firstPublishYear: 1960,
                    localCoverName: "105",
                    description: "Роман Харпер Ли, рассказывающий о расовой несправедливости и разрушении детской невинности. История unfolds через глаза юной Джин Луизы Финч по прозвищу Глазастик."
                )
            ]
        default:
            mockBooks = [
                Book(
                    key: "/works/OL7W",
                    title: "\(query.capitalized)",
                    authorName: ["Various Authors"],
                    publishYear: [2020],
                    isbn: ["9780000000000"],
                    coverI: -7,
                    firstPublishYear: 2020,
                    localCoverName: "106",
                    description: "Интересная книга на тему '\(query)'. Подробное описание и увлекательный сюжет не оставят вас равнодушными."
                )
            ]
        }
        
        let delay = Double.random(in: 0.5...2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion(.success(mockBooks))
        }
    }
}
