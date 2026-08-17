//
//  ViewController.swift
//  eCommerce
//
//  Created by Rene Cabañas Lopez on 17/08/26.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        testViewModel()
    }

    private func testViewModel() {

        let apiClient = APIClient()

        let walmartService = WalmartService(
            apiClient: apiClient
        )

        let viewModel = SearchViewModel(
            walmartService: walmartService
        )

        Task {
            await viewModel.search(keyword: "nintendo")

            print("Productos encontrados: \(viewModel.products.count)")

            if let firstProduct = viewModel.products.first {
                print("Nombre: \(firstProduct.name)")
                print("Precio: \(firstProduct.price)")
                print("Imagen: \(firstProduct.image)")
            }
        }
    }
}
