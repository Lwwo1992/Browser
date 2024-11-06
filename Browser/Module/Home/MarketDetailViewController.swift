//
//  MarketDetailViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/22.
//

import UIKit

class MarketDetailViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(MarketDetailView(model: model))
    }

    var model = MarketModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MarketDetailViewController {
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
