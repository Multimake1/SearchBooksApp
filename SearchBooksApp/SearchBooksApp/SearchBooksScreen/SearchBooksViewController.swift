//
//  SearchBooksViewController.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//
import UIKit

protocol ISearchBooksViewController: AnyObject {
    func configureNavigationBar()
    func clearCacheTapped()
    func showClearCacheOptions()
    func showAlert(message: String)
}

final class SearchBooksViewController: UIViewController {
    private var searchBooksPresenter: ISearchBooksPresenter
    private var searchBooksView: SearchBooksView
    
    struct Dependencies {
        let presenter: ISearchBooksPresenter
    }
    
    init(dependencies: Dependencies) {
        self.searchBooksView = SearchBooksView()
        self.searchBooksPresenter = dependencies.presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = searchBooksView
        self.searchBooksPresenter.loadView(view: self.searchBooksView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        searchBooksPresenter.loadInitialBooks()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupDelegates()
        configureNavigationBar()
        setupNavigationBarButtons()
    }
    
    private func setupDelegates() {
        searchBooksView.booksTableView.dataSource = self
        searchBooksView.booksTableView.delegate = self
        searchBooksView.searchController.searchBar.delegate = self
    }
    
    private func setupNavigationBarButtons() {
        let clearCacheButton = UIBarButtonItem(
            title: "Очистить кэш",
            style: .plain,
            target: self,
            action: #selector(clearCacheTapped)
        )
        
        let themeButton = UIBarButtonItem(
            image: UIImage(systemName: ThemeManager.shared.isDarkTheme ? "sun.max" : "moon"),
            style: .plain,
            target: self,
            action: #selector(toggleThemeTapped)
        )
        
        navigationItem.rightBarButtonItem = clearCacheButton
        navigationItem.leftBarButtonItem = themeButton
    }
    
    @objc private func toggleThemeTapped() {
        ThemeManager.shared.toggleTheme()
        updateThemeButtonIcon()
        showThemeChangeMessage()
    }
        
    private func updateThemeButtonIcon() {
        if let themeButton = navigationItem.leftBarButtonItems?.last {
            themeButton.image = UIImage(systemName: ThemeManager.shared.isDarkTheme ? "sun.max" : "moon")
        }
    }
        
    private func showThemeChangeMessage() {
        let themeName = ThemeManager.shared.isDarkTheme ? "темная" : "светлая"
        let alert = UIAlertController(
            title: "Тема изменена",
            message: "Установлена \(themeName) тема",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SearchBooksViewController: ISearchBooksViewController {
    func configureNavigationBar() {
        navigationItem.searchController = searchBooksView.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "Поиск книг"
    }
    
    @objc func clearCacheTapped() {
        showClearCacheOptions()
    }
    
    func showClearCacheOptions() {
        let alert = UIAlertController(
            title: "Очистка кэша",
            message: "Выберите действие",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Очистить старый кэш (старше 7 дней)", style: .default) { _ in
            self.searchBooksPresenter.clearSevenDaysCache()
            self.showAlert(message: "Старый кэш очищен")
        })
        
        alert.addAction(UIAlertAction(title: "Очистить весь кэш", style: .destructive) { _ in
            self.searchBooksPresenter.clearAllCache()
            self.showAlert(message: "Весь кэш очищен")
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SearchBooksViewController: ISearchBooksView {
    func showBooks(books: [Book]) {
        searchBooksView.showBooks(books: books)
    }
    
    func showError(error: String) {
        searchBooksView.showError(error: error)
    }
    
    func showLoading() {
        searchBooksView.showLoading()
    }
    
    func hideLoading() {
        searchBooksView.hideLoading()
    }
    
    func showEmptyState() {
        searchBooksView.showEmptyState()
    }
    
    func showInitialState() {
        searchBooksView.showInitialState()
    }
}

extension SearchBooksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchBooksPresenter.numberOfBooks()
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.identifier, for: indexPath) as? BookTableViewCell,
              let book = searchBooksPresenter.book(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let isCached = searchBooksPresenter.isBookFromCache(at: indexPath.row)
        cell.configure(with: book, isCached: isCached)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let book = searchBooksPresenter.book(at: indexPath.row) else { return }
        searchBooksPresenter.didSelectBook(book: book)
    }
}

extension SearchBooksViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        print("\(query)")
        searchBooksPresenter.searchBooks(query: query)
        
        searchBooksView.searchController.dismiss(animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBooksPresenter.loadInitialBooks()
    }
}


