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

    override func awakeFromNib() {
        super.awakeFromNib()

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
        priceLabel.text = product.price == "N/A"
            ? "Price unavailable"
            : "$\(product.price)"

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
}
