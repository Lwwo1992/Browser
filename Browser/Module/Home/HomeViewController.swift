//
//  HomeViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class HomeViewController: ViewController {
    private var viewModel = HomeViewModel()

    override var rootView: AnyView? {
        return AnyView(HomeView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        viewModel.fetchMarketList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension HomeViewController {
    override func initUI() {
        super.initUI()
        setupGradientBackground()
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.red.withAlphaComponent(0.6).cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
