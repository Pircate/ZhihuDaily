//
//  HomeNewsRowCell.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import Hue

class HomeNewsRowCell: UITableViewCell {
    
    var model: HomeNewsModel? {
        didSet {
            titleLabel.text = model?.title
            if let url = model?.images.first {
                coverImageView.kf.setImage(with: URL(string: url))
            }
        }
    }
    
    lazy var coverImageView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#333333")
        label.numberOfLines = 0
        return label
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
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 44))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(coverImageView.snp.left).offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeNewsRowCell: Updatable {
    typealias ViewData = HomeNewsModel
    
    func update(viewData: HomeNewsModel) {
        titleLabel.text = viewData.title
        if let url = viewData.images.first {
            coverImageView.kf.setImage(with: URL(string: url))
        }
    }
}
