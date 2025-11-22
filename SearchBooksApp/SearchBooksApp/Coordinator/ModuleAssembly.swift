//
//  ModuleAssembly.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

protocol IModulesFactory {
    func makeSearchBooksScreen(parameters: SearchBooksAssembly.Parameters) -> UIViewController
    func makeBookDetailScreen(parameters: BookDetailAssembly.Parameters) -> UIViewController
}

final class ModulesFactory {
    init() {

    }
}

extension ModulesFactory: IModulesFactory {
    func makeSearchBooksScreen(parameters: SearchBooksAssembly.Parameters) -> UIViewController {
        SearchBooksAssembly.build(with: parameters)
    }
    
    func makeBookDetailScreen(parameters: BookDetailAssembly.Parameters) -> UIViewController {
        BookDetailAssembly.build(with: parameters)
    }
}
