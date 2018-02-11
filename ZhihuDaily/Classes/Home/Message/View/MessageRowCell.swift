//
//  MessageRowCell.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/2/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

class MessageRowCell: UITableViewCell {
    
    lazy var badgeImageView: UIImageView = {
        let badgeImageView = UIImageView(image: #imageLiteral(resourceName: "message_row_badge"))
        return badgeImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.global
        return titleLabel
    }()
    
    lazy var introLabel: UILabel = {
        let introLabel = UILabel()
        introLabel.font = UIFont.systemFont(ofSize: 11)
        introLabel.textColor = UIColor.global.alpha(0.81)
        return introLabel
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSubviews() {
        
    }
}
