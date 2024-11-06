//
//  DropdownCell.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class DropdownCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    static let reuseIdentifier = "DropdownCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 自定义图标
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)

        // 自定义文字标签
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)

        // 使用 SnapKit 布局
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 配置 Cell 方法
    func configure(with record: RecordModel) {
        titleLabel.text = record.name
        
        let imageUrl = Util.getImageUrl(from: record.logo)
        iconImageView.setImage(with: imageUrl)
    }
}
