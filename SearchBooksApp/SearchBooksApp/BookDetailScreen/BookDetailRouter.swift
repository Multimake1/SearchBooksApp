//
//  BookDetailRouter.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

protocol IBookDetailRouter: AnyObject {
    func showBookGetHandler(with book: Book)
    func showRecommendedBookDetailHandler(with book: Book)
    func dismissHandler()
}

final class BookDetailRouter {
    private let showGetBookModalHandler: (Book) -> Void
    private let showBookDetailHandler: (Book) -> Void
    private let closeToRootHandler: () -> Void
    
    init(showGetBookModalHandler: @escaping (Book) -> Void,
         showBookDetailHandler: @escaping (Book) -> Void,
         closeToRootHandler: @escaping () -> Void) {
        self.showGetBookModalHandler = showGetBookModalHandler
        self.showBookDetailHandler = showBookDetailHandler
        self.closeToRootHandler = closeToRootHandler
    }
}

extension BookDetailRouter: IBookDetailRouter {
    func showBookGetHandler(with book: Book) {
        self.showGetBookModalHandler(book)
    }
    
    func showRecommendedBookDetailHandler(with book: Book) {
        self.showBookDetailHandler(book)
    }
    
    func dismissHandler() {
        self.closeToRootHandler()
    }
}
