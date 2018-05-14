//
//  HomeNewsRowCell.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import Hue
import CocoaChainKit

final class HomeNewsRowCell: UITableViewCell {
    
    lazy var coverImageView: UIImageView = {
        return UIImageView()
    }()
    
    lazy var titleLabel: UILabel = {
        return UILabel().chain.systemFont(ofSize: 14).textColor(UIColor(hex: "#333333")).numberOfLines(0).build
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(coverImageView)
        
        coverImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 44))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(15)
            make.right.equalTo(coverImageView.snp.left).offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeNewsRowCell: Updatable {
    
    func update(_ item: HomeNewsModel) {
        titleLabel.text = item.title
        coverImageView.hero.id = item.id
        if let url = item.images.first {
            coverImageView.kf.setImage(with: URL(string: url))
        }
    }
}
