//
//  ProductCollectionViewCell.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import UIKit

final class ProductCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ProductCollectionViewCell"
    
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCardStyle()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        productImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
    }
    
    func configure(with product: WalmartProductDTO) {
        
        titleLabel.text = product.displayName
        
        let price = product.price
        
        priceLabel.text = price == "N/A"
        ? "Price unavailable"
        : "$\(price)"
        
        productImageView.image = UIImage(systemName: "photo")
        
        guard let url = product.thumbnailURL else {
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard let image = UIImage(data: data) else {
                    return
                }
                
                await MainActor.run {
                    self.productImageView.image = image
                }
                
            } catch {
                print("Error loading image:", error)
            }
        }
    }
    
    private func configureUI() {
        
        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 2
        
        priceLabel.font = .boldSystemFont(ofSize: 16)
    }
    
    func configureCardStyle() {
        
        contentView.backgroundColor = .systemBackground
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(
            width: 0,
            height: 2
        )
        layer.shadowRadius = 6
    }
    
}
