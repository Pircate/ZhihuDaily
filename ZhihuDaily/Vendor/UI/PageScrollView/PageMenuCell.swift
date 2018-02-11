//
//  PageMenuCell.swift
//  FirstJapaneseLife
//
//  Created by G-Xi0N on 2017/12/14.
//  Copyright © 2017年 G-Xi0N. All rights reserved.
//

import UIKit

final class PageMenuCell: UICollectionViewCell {

    private let underlineHeight: CGFloat = 2.0
    private let backgroundLayerHeight: CGFloat = 3.0

    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: backgroundLayerHeight)
        return layer
    }()

    lazy var titleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = contentView.bounds
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    lazy var underline: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: contentView.center.x, y: contentView.bounds.height - underlineHeight, width: 0, height: underlineHeight)
        return layer
    }()

    public var title: String = "" {
        didSet {
            titleButton.setTitle(title, for: .normal)
        }
    }

    private static var deselectDisabled = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            PageMenuCell.deselectDisabled = isHighlighted
        }
    }

    override var isSelected: Bool {
        didSet {
            let flag = PageMenuCell.deselectDisabled ? oldValue : isSelected
            titleButton.isSelected = flag
            backgroundLayer.frame.size.height = flag ? contentView.bounds.height : backgroundLayerHeight
            underline.frame.origin.x = flag ? 15 : contentView.center.x
            underline.frame.size.width = flag ? contentView.bounds.width - 30 : 0
        }
    }

    // MARK: - private
    private func addSubviews() {
        contentView.layer.addSublayer(backgroundLayer)
        contentView.addSubview(titleButton)
        contentView.layer.addSublayer(underline)
    }
}
