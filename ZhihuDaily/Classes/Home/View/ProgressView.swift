//
//  ProgressView.swift
//  ChengTayTong
//
//  Created by G-Xi0N on 2018/2/13.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base == ProgressView {
    internal var stop: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.stopLoading()
        }
    }
}

class ProgressView: UIView {

    public var progress: CGFloat = 0 {
        didSet {
            guard !indicatorView.isAnimating else { return }
            setNeedsDisplay()
        }
    }
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = bounds
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 4
        return layer
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicatorView.frame = bounds
        return indicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
        
        addSubview(indicatorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let width = bounds.width
        let path = UIBezierPath(arcCenter: CGPoint(x: width, y: width), radius: width / 2, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2 * progress, clockwise: true)
        progressLayer.path = path.cgPath
        layer.addSublayer(progressLayer)
    }
    
    public func startLoading() {
        progress = 0
        indicatorView.startAnimating()
    }
    
    public func stopLoading() {
        indicatorView.stopAnimating()
    }
}
