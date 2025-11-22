//
//  SearchBooksView.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

protocol ISearchBooksView: AnyObject {
    func showBooks(books: [Book])
    func showError(error: String)
    func showLoading()
    func hideLoading()
    func showEmptyState()
    func showInitialState()
}

final class SearchBooksView: UIView {
    lazy var booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.rowHeight = 100
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите название книги, автора или ISBN"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.returnKeyType = .search
        return searchController
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemGray
        return indicator
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = false
        return view
    }()
    
    private lazy var errorStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(booksTableView)
        addSubview(emptyStateView)
        addSubview(errorStateView)
        addSubview(loadingIndicator)
        
        setupConstraints()
        showInitialState()
    }
    
    private func setupConstraints() {
        booksTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        booksTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        booksTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        booksTableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        emptyStateView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emptyStateView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        errorStateView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        errorStateView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        errorStateView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        errorStateView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

extension SearchBooksView: ISearchBooksView {
    func showBooks(books: [Book]) {
        updateUIForState(hasBooks: !books.isEmpty)
        booksTableView.reloadData()
    }
    
    func showError(error: String) {
        updateUIForState(hasBooks: false, hasError: true, errorMessage: error)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        updateUIForState(hasBooks: false)
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func showEmptyState() {
        emptyStateView.configure(
            icon: "book.closed",
            title: "Книги не найдены",
            message: "Попробуйте изменить поисковый запрос"
        )
        updateUIForState(hasBooks: false)
    }
    
    func showInitialState() {
        emptyStateView.configure(
            icon: "magnifyingglass",
            title: "Поиск книг",
            message: "Введите название книги, автора или ISBN для поиска"
        )
        updateUIForState(hasBooks: false)
    }
    
    private func updateUIForState(hasBooks: Bool, hasError: Bool = false, errorMessage: String? = nil) {
        booksTableView.isHidden = !hasBooks || hasError
        emptyStateView.isHidden = hasBooks || hasError
        errorStateView.isHidden = !hasError
        
        if let errorMessage = errorMessage {
            errorStateView.configure(
                icon: "exclamationmark.triangle",
                title: "Ошибка",
                message: errorMessage
            )
        }
    }
}
