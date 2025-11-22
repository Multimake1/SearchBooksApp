//
//  BookDetailViewController.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

final class BookDetailViewController: UIViewController {
    private var presenter: IBookDetailPresenter
    private var bookDetailView: BookDetailView

    struct Dependencies {
        let presenter: IBookDetailPresenter
    }
    
    init(dependencies: Dependencies) {
        self.bookDetailView = BookDetailView()
        self.presenter = dependencies.presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = bookDetailView
        self.presenter.loadView(view: self.bookDetailView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Детали книги"
        navigationItem.largeTitleDisplayMode = .never
    }
}
