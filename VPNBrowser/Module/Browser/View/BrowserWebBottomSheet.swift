//
//  BrowserWebBottomSheet.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class BrowserWebBottomSheet: UIView {
    let items = [
//        ("书签", "bookmark.fill"),
        ("历史", "clock.fill"),
        ("下载", "arrow.down.circle.fill"),
        ("收藏", "star.fill"),
        ("分享", "square.and.arrow.up.fill"),
    ]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookmarkCell.self, forCellWithReuseIdentifier: BookmarkCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserWebBottomSheet: UICollectionViewDelegate, UICollectionViewDataSource {
    private func initUI() {
        backgroundColor = .white
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCell.reuseIdentifier, for: indexPath) as? BookmarkCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        cell.configure(title: item.0, imageName: item.1)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tf_hide()

        let item = items[indexPath.item]
        switch item.0 {
        case "历史":
            Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 1), animated: true)
        case "收藏":
            Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 0), animated: true)
        default:
            break
        }
    }
}

class BookmarkCell: UICollectionViewCell {
    static let reuseIdentifier = "BookmarkCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, imageName: String) {
        titleLabel.text = title
        imageView.image = UIImage(systemName: imageName)
    }
}
