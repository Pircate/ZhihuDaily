//
//  PageMenuView.swift
//  FirstJapaneseLife
//
//  Created by G-Xi0N on 2017/12/14.
//  Copyright © 2017年 G-Xi0N. All rights reserved.
//

import UIKit

class PageMenuView: UIView {

    public var titles: [String] = [] {
        didSet {
            guard titles.count > 0 else { return }
            
            for index in 0..<titles.count {
                collectionView.register(PageMenuCell.self, forCellWithReuseIdentifier: "PageMenuCell_\(index)")
            }
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    public var didSelectItemHandler: ((Int) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        return collectionView
    }()

    private lazy var itemWidths: [CGFloat] = {
        titles.map({
            CGFloat($0.count * 15 + 30)
        })
    }()

    private var currentIndex = 0
    private var normalColor = UIColor.black
    private var selectedColor = UIColor.blue
    private var underlineColor = UIColor.blue
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }

    // MARK: - private
    private func addSubviews() {
        addSubview(collectionView)
    }

    // MARK: - public
    public func selectItem(at index: Int) {

        guard currentIndex != index else { return }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        currentIndex = index
    }
    
    public func configureItemStyle(normalColor: UIColor,
                                   selectedColor: UIColor,
                                   underlineColor: UIColor,
                                   backgroundLayerColor: UIColor = .clear) {
        self.normalColor = normalColor
        self.selectedColor = selectedColor
        self.underlineColor = underlineColor
    }
}

// MARK: - UICollectionViewDataSource
extension PageMenuView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PageMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageMenuCell_\(indexPath.item)", for: indexPath) as! PageMenuCell
        cell.titleButton.setTitleColor(normalColor, for: .normal)
        cell.titleButton.setTitleColor(selectedColor, for: .selected)
        cell.underline.backgroundColor = underlineColor.cgColor
        cell.title = titles[indexPath.item]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PageMenuView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        guard currentIndex != indexPath.item else {
            return
        }
        currentIndex = indexPath.item
        didSelectItemHandler.map({
            $0(currentIndex)
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PageMenuView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidths[indexPath.item], height: bounds.height)
    }
}
