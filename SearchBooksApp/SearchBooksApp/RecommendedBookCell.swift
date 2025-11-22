//
//  RecommendedBookCell.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import UIKit

final class RecommendedBookCell: UICollectionViewCell {
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        
        if book.hasLocalCover, let localImage = book.localCoverImage {
            coverImageView.image = localImage
            coverImageView.contentMode = .scaleAspectFill
        } else if let coverURL = book.coverURL {
            loadImage(from: coverURL)
        } else {
            setPlaceholderImage()
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.coverImageView.image = image
                    self.coverImageView.contentMode = .scaleAspectFill
                }
            } else {
                DispatchQueue.main.async {
                    self.setPlaceholderImage()
                }
            }
        }
    }
    
    private func setPlaceholderImage() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .light)
        let placeholderImage = UIImage(systemName: "book.closed", withConfiguration: config)
        coverImageView.image = placeholderImage
        coverImageView.tintColor = .systemGray3
        coverImageView.contentMode = .center
    }
}
