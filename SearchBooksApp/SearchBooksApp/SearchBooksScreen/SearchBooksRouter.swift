//
//  SearchBooksRouter.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

protocol ISearchBooksRouter: AnyObject {
    func showBooksDetailHandler(with book: Book)
}

final class SearchBooksRouter {
    private let showBooksDetail: (Book) -> Void
    
    init(showBooksDetail: @escaping (Book) -> Void) {
        self.showBooksDetail = showBooksDetail
    }
}

extension SearchBooksRouter: ISearchBooksRouter  {
    func showBooksDetailHandler(with book: Book) {
        self.showBooksDetail(book)
    }
}
