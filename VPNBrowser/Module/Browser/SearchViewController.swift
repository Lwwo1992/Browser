//
//  SearchViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import UIKit

class SearchViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(SearchView())
    }

    private lazy var textField = TextField().then {
        $0.placeholder = "搜索"
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var selctedButton = UIView().then { view in
        let imageView = UIImageView().then {
            $0.image = UIImage(resource: .baidu)
        }
        let arrow = UIImageView().then {
            $0.image = UIImage(resource: .arrowBottom)
        }

        view.addSubview(imageView)
        view.addSubview(arrow)

        imageView.snp.makeConstraints { make in
            make.size.equalTo(15)
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints { make in
            make.size.equalTo(10)
            make.left.equalTo(imageView.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
    }

    private lazy var searchBarView = UIView().then { view in
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.backgroundColor = .white

        let searchBarWidth = Util.deviceWidth - 100
        view.frame = CGRect(x: 0, y: 0, width: searchBarWidth, height: 35)

        [selctedButton, textField].forEach {
            view.addSubview($0)
        }

        selctedButton.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
        textField.frame = CGRect(x: selctedButton.right, y: 0, width: searchBarWidth - 100, height: 35)
    }

    private lazy var goToButton = Button().then {
        $0.title("前往")
            .titleFont(.systemFont(ofSize: 14))
            .titleColor(.blue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selctedButton.addBorder(to: .right, color: UIColor.gray, thickness: 1)
    }
}

extension SearchViewController {
    override func initUI() {
        super.initUI()

        navigationItem.titleView = searchBarView
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: goToButton)
    }
}
