//
//  BookDetailAssembly.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

final class BookDetailAssembly {
    struct Parameters {
        let showGetBookModalHandler: (Book) -> Void
        let showBookDetailHandler: (Book) -> Void
        let closeToRootHandler: () -> Void
        let book: Book
    }

    static func build(with parameters: Parameters) -> UIViewController {
        let bookDescriptionService = BookDescriptionService()
        let bookRecommendationService = BookRecommendationService()
        let interactor = BookDetailInteractor(bookDescriptionService: bookDescriptionService,                                                        bookRecommendationService: bookRecommendationService)
        let router = BookDetailRouter(showGetBookModalHandler: parameters.showGetBookModalHandler,
                                      showBookDetailHandler: parameters.showBookDetailHandler,
                                      closeToRootHandler: parameters.closeToRootHandler)
        let presenter = BookDetailPresenter(dependecies: .init(router: router,
                                                               book: parameters.book,
                                                               interactor: interactor))
        let viewController = BookDetailViewController(dependencies: .init(presenter: presenter))
        
        return viewController
    }
}
