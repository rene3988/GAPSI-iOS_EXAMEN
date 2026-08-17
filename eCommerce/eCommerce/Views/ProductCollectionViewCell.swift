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

        configureAppearance()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        productImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
    }

    func configure(with product: WalmartProductDTO) {

        //titleLabel.text = product.title
       // priceLabel.text = "$\(product.price)"

        // Lo implementaremos después.
        // Aquí cargaremos product.thumbnail.
    }

    private func configureAppearance() {
        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true

        titleLabel.numberOfLines = 2

        priceLabel.font = .boldSystemFont(ofSize: 16)
    }
}
