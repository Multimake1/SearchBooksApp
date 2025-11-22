//
//  BookDetailView.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

protocol IBookDetailView: AnyObject {
    var onGetBookButtonTapped: (() -> Void)? { get set }
    var onCloseButtonTapped: (() -> Void)? { get set }
    var onRecommendedBookSelected: ((Book) -> Void)? { get set }
    
    func displayBookDetails(book: Book)
    func displayError(message: String)
    func updateDescription(description: String)
    func displayRecommendedBooks(books: [Book])
}

final class BookDetailView: UIView {
    private var recommendedBooks: [Book] = []
    var onGetBookButtonTapped: (() -> Void)?
    var onCloseButtonTapped: (() -> Void)?
    var onRecommendedBookSelected: ((Book) -> Void)?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var getBookButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Получить книгу", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Закрыть", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Описание"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }()
    
    private lazy var descriptionLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var recommendationsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Вам может быть интересно"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.isHidden = true
        return label
    }()
       
    private lazy var recommendationsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.minimumLineSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        collectionView.register(RecommendedBookCell.self, forCellWithReuseIdentifier: "RecommendedBookCell")
        return collectionView
    }()
       
    private lazy var recommendationsLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(getBookButton)
        contentView.addSubview(closeButton)
        
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionLoadingIndicator)
        
        addSubview(recommendationsTitleLabel)
        addSubview(recommendationsCollectionView)
        addSubview(recommendationsLoadingIndicator)
    }
    
    private func setupConstraints() {
        scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 24).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        infoStackView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 32).isActive = true
        infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        descriptionTitleLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24).isActive = true
        descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        descriptionLoadingIndicator.centerXAnchor.constraint(equalTo: descriptionLabel.centerXAnchor).isActive = true
        descriptionLoadingIndicator.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 20).isActive = true
        
        getBookButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32).isActive = true
        getBookButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: getBookButton.bottomAnchor, constant: 16).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24).isActive = true
        
        recommendationsTitleLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 32).isActive = true
        recommendationsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        recommendationsTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        recommendationsCollectionView.topAnchor.constraint(equalTo: recommendationsTitleLabel.bottomAnchor, constant: 12).isActive = true
        recommendationsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        recommendationsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        recommendationsCollectionView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        recommendationsLoadingIndicator.centerXAnchor.constraint(equalTo: recommendationsCollectionView.centerXAnchor).isActive = true
        recommendationsLoadingIndicator.centerYAnchor.constraint(equalTo: recommendationsCollectionView.centerYAnchor).isActive = true
        
        recommendationsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
    }
    
    private func setupActions() {
        getBookButton.addTarget(self, action: #selector(getBookButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        recommendationsCollectionView.dataSource = self
        recommendationsCollectionView.delegate = self
    }
    
    @objc private func getBookButtonTapped() {
        onGetBookButtonTapped?()
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    
    private func createInfoRow(title: String, value: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        
        let titleLabel = UILabel()
        titleLabel.text = title + ":"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        return stackView
    }
    
    private func loadImage(from url: URL?) {
        guard let url = url else {
            setPlaceholderImage()
            return
        }
        
        setPlaceholderImage()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                DispatchQueue.main.async {
                    self?.coverImageView.image = image
                    self?.coverImageView.contentMode = .scaleAspectFill
                    self?.coverImageView.backgroundColor = .clear
                }
            } catch {
                DispatchQueue.main.async {
                    self?.setPlaceholderImage()
                }
            }
        }
    }
    
    private func loadLocalImage(image: UIImage?) {
        if let image = image {
            coverImageView.image = image
            coverImageView.contentMode = .scaleAspectFill
            coverImageView.backgroundColor = .clear
        } else {
            setPlaceholderImage()
        }
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light, scale: .medium)
        let placeholderImage = UIImage(systemName: "book.closed", withConfiguration: config)
        coverImageView.image = placeholderImage
        coverImageView.tintColor = .systemGray3
        coverImageView.contentMode = .center
        coverImageView.backgroundColor = .systemGray6
    }
}

extension BookDetailView: IBookDetailView {
    func displayBookDetails(book: Book) {
        titleLabel.text = book.title ?? "Неизвестное название"
        authorLabel.text = book.authorsText
        
        if let description = book.description, !description.isEmpty {
            descriptionLabel.text = description
            descriptionLoadingIndicator.stopAnimating()
        } else {
            descriptionLabel.text = "Загрузка описания..."
            descriptionLoadingIndicator.startAnimating()
        }
        
        if book.hasLocalCover, let localImage = book.localCoverImage {
            loadLocalImage(image: localImage)
        } else {
            loadImage(from: book.coverURL)
        }
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let firstPublishYear = book.firstPublishYear, firstPublishYear > 0 {
            let yearRow = createInfoRow(title: "Год издания", value: "\(firstPublishYear)")
            infoStackView.addArrangedSubview(yearRow)
        }
        
        if let publishYears = book.publishYear, !publishYears.isEmpty {
            let yearsText = publishYears.map { String($0) }.joined(separator: ", ")
            let yearsRow = createInfoRow(title: "Годы издания", value: yearsText)
            infoStackView.addArrangedSubview(yearsRow)
        }
        
        if let isbn = book.isbn, !isbn.isEmpty {
            let isbnText = isbn.joined(separator: ", ")
            let isbnRow = createInfoRow(title: "ISBN", value: isbnText)
            infoStackView.addArrangedSubview(isbnRow)
        }
        
        if infoStackView.arrangedSubviews.isEmpty {
            let noInfoLabel = UILabel()
            noInfoLabel.text = "Дополнительная информация отсутствует"
            noInfoLabel.font = .systemFont(ofSize: 16, weight: .regular)
            noInfoLabel.textColor = .tertiaryLabel
            noInfoLabel.textAlignment = .center
            infoStackView.addArrangedSubview(noInfoLabel)
        }
    }
    
    func displayError(message: String) {
        print("Error: \(message)")
    }
    
    func updateDescription(description: String) {
        descriptionLabel.text = description
        descriptionLoadingIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.descriptionLabel.alpha = 1.0
        }
    }
    
    func displayRecommendedBooks(books: [Book]) {
        self.recommendedBooks = books
        
        if books.isEmpty {
            recommendationsTitleLabel.isHidden = true
            recommendationsCollectionView.isHidden = true
        } else {
            recommendationsTitleLabel.isHidden = false
            recommendationsCollectionView.isHidden = false
            recommendationsCollectionView.reloadData()
            recommendationsLoadingIndicator.stopAnimating()
        }
    }
}

extension BookDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedBookCell", for: indexPath) as! RecommendedBookCell
        let book = recommendedBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = recommendedBooks[indexPath.item]
        onRecommendedBookSelected?(book)
    }
}
