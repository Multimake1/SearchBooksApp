//
//  SearchBooksAssembly.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

final class SearchBooksAssembly {
    struct Parameters {
        let showBooksDetailScreenHandler: (Book) -> Void
    }

    static func build(with parameters: Parameters) -> UIViewController {
        let searchBooksService = SmartSearchBooksService()
        let interactor = SearchBooksInteractor(searchBooksService: searchBooksService)
        let router = SearchBooksRouter(showBooksDetail: parameters.showBooksDetailScreenHandler)
        let presenter = SearchBooksPresenter(dependecies: .init(router: router,
                                                                interactor: interactor))
        let viewController = SearchBooksViewController(
            dependencies: .init(presenter: presenter)
        )
        
        return viewController
    }
}
