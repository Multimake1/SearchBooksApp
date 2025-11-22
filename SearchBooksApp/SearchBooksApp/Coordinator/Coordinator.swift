//
//  Coordinator.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

final class Coordinator {
    private let navigationController: UINavigationController
    private let modulesFactory: IModulesFactory

    init(navigationController: UINavigationController, modulesFactory: IModulesFactory) {
        self.navigationController = navigationController
        self.modulesFactory = modulesFactory
    }

    func start() {
        let showBookDetailHandler: (Book) -> Void = { [weak self] book in
            self?.showBookDetailScreen(with: book)
        }
        
        let parameters = SearchBooksAssembly.Parameters(showBooksDetailScreenHandler: showBookDetailHandler)
        
        let mainVC = self.modulesFactory.makeSearchBooksScreen(parameters: parameters)
        navigationController.setViewControllers([mainVC], animated: false)
    }
    
    func showBookDetailScreen(with book: Book) {
        let showGetBookModalHandler: (Book) -> Void = { [weak self] book in
            self?.presentGetBookModal(with: book)
        }
        
        let showBookDetailHandler: (Book) -> Void = { [weak self] book in
            self?.showBookDetailScreen(with: book)
        }
        
        let closeToRootHandler: () -> Void = { [weak self] in
            self?.closeToRoot()
        }
        
        let parameters = BookDetailAssembly.Parameters(
            showGetBookModalHandler: showGetBookModalHandler,
            showBookDetailHandler: showBookDetailHandler,
            closeToRootHandler: closeToRootHandler,
            book: book
        )
        
        let detailBookVC = self.modulesFactory.makeBookDetailScreen(parameters: parameters)
        navigationController.pushViewController(detailBookVC, animated: true)
    }
    
    //для получения книги нужно перейти на сайт, потому что для дальнейшей разработки нужен аккаунт и т.д.
    func presentGetBookModal(with book: Book) {
        let alert = UIAlertController(
            title: "Получить книгу",
            message: "Для получения книги \"\(book.title ?? "Неизвестное название")\" перейдите на сайт Open Library",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Перейти на сайт", style: .default) { _ in
            if let workId = book.workId,
               let url = URL(string: "https://openlibrary.org/works/\(workId)") {
                UIApplication.shared.open(url)
            } else if let url = URL(string: "https://openlibrary.org") {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigationController.present(alert, animated: true)
    }
    
    private func closeToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}

    
    
    
