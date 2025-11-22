//
//  BookCell.swift
//  FinalProject
//
//  Created by Арсений on 20.11.2025.
//

import UIKit

final class BookTableViewCell: UITableViewCell {
    static let identifier = "BookTableViewCell"
    private var currentImageURL: URL?
    
    private lazy var bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray6
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.separator.cgColor
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private lazy var cacheIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bookCoverImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(cacheIndicator)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(yearLabel)
        
        setupConstraints()
        setupTheme()
    }
    
    private func setupConstraints() {
        bookCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        bookCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        bookCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        bookCoverImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bookCoverImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: bookCoverImageView.trailingAnchor, constant: 12).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        
        cacheIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        cacheIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        cacheIndicator.widthAnchor.constraint(equalToConstant: 8).isActive = true
        cacheIndicator.heightAnchor.constraint(equalToConstant: 8).isActive = true
    }
    
    private func setupTheme() {
        contentView.backgroundColor = .systemBackground
        backgroundColor = .systemBackground
    }
    
    func configure(with book: Book, isCached: Bool = false) {
        titleLabel.text = book.title ?? "Unknown Title"
        authorLabel.text = book.authorsText
        yearLabel.text = book.yearText
        
        cacheIndicator.isHidden = !isCached
        
        if book.hasLocalCover {
            loadLocalImage(book.localCoverImage)
        } else {
            loadImage(from: book.coverURL)
        }
    }
    
    private func loadLocalImage(_ image: UIImage?) {
        if let image = image {
            bookCoverImageView.image = image
            bookCoverImageView.contentMode = .scaleAspectFill
            bookCoverImageView.backgroundColor = .clear
        } else {
            setPlaceholderImage()
        }
    }
    
    private func loadImage(from url: URL?) {
        bookCoverImageView.image = nil
        currentImageURL = url
        
        guard let url = url else {
            setPlaceholderImage()
            return
        }
        
        setPlaceholderImage()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, self.currentImageURL == url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                DispatchQueue.main.async {
                    if self.currentImageURL == url {
                        self.bookCoverImageView.image = image
                        self.bookCoverImageView.contentMode = .scaleAspectFill
                        self.bookCoverImageView.backgroundColor = .clear
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if self.currentImageURL == url {
                        self.setPlaceholderImage()
                    }
                }
            }
        }
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .light, scale: .medium)
        let placeholderImage = UIImage(systemName: "book.closed", withConfiguration: config)
        bookCoverImageView.image = placeholderImage
        bookCoverImageView.tintColor = .systemGray3
        bookCoverImageView.contentMode = .center
        bookCoverImageView.backgroundColor = .systemGray6
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookCoverImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        yearLabel.text = nil
        cacheIndicator.isHidden = true
        currentImageURL = nil
        bookCoverImageView.backgroundColor = .systemGray6
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupTheme()
        }
    }
}
