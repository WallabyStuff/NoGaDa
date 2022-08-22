//
//  Selector.swift
//  CustomSegmentedControl
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

@objc
protocol BISegmentedControlDelegate: AnyObject {
    @objc optional
    func BISegmentedControl(didSelectSegmentAt index: Int)
}

class BISegmentedControl: UIView {
    
    weak var delegate: BISegmentedControlDelegate?
    private let segmentedStackView = UIStackView()
    private let barIndicatorView = UIView()
    private var barIndicatorLeftAnchor: NSLayoutConstraint?
    private var barIndicatorwidthAnchor: NSLayoutConstraint?
    public var barIndicatorWidthProportion: CGFloat = 0.7
    public var barIndicatorColor: UIColor = ColorSet.updatedSongSelectorBarIndicatorColor
    public var barIndicatorHeight: CGFloat = 4
    public var currentPosition = 0
    public var segmentTintColor: UIColor = .black
    public var segmentDefaultColor: UIColor = .gray
    public var segmentFontSize: CGFloat = 17
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        configureBarIndicator()
        configureStackView()
        DispatchQueue.main.async {
            self.changeIndicatorPosition()
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSegmentendControl(_:))))
    }
    
    private func configureBarIndicator() {
        barIndicatorView.backgroundColor = barIndicatorColor
        barIndicatorView.layer.cornerRadius = barIndicatorHeight / 2
        addSubview(barIndicatorView)
        barIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        barIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        barIndicatorView.heightAnchor.constraint(equalToConstant: barIndicatorHeight).isActive = true
        
        barIndicatorwidthAnchor = barIndicatorView.widthAnchor.constraint(equalToConstant: 0)
        barIndicatorwidthAnchor!.isActive = true
        
        barIndicatorLeftAnchor = barIndicatorView.leftAnchor.constraint(equalTo: leftAnchor)
        barIndicatorLeftAnchor!.isActive = true
    }
    
    private func configureStackView() {
        segmentedStackView.axis = .horizontal
        segmentedStackView.distribution = .fillEqually
        segmentedStackView.backgroundColor = .clear
        addSubview(segmentedStackView)
        segmentedStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentedStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        segmentedStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        segmentedStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        segmentedStackView.bottomAnchor.constraint(equalTo: barIndicatorView.topAnchor).isActive = true
    }
    
    private func changeIndicatorPosition() {
        if segmentedStackView.arrangedSubviews.count == 0 {
            return
        }
        
        let barIndicatorWidth = segmentedStackView.arrangedSubviews[currentPosition].frame.width * barIndicatorWidthProportion
        let barIndicatorXPosition = segmentedStackView.arrangedSubviews[currentPosition].frame.origin.x
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [.allowUserInteraction, .curveEaseInOut]) {
            self.barIndicatorwidthAnchor?.constant = barIndicatorWidth
            self.barIndicatorLeftAnchor?.constant = barIndicatorXPosition
            self.layoutIfNeeded()
        }
        
        for (index, segmentLabel) in segmentedStackView.arrangedSubviews.enumerated() {
            guard let segmentLabel = segmentLabel as? UILabel else {
                return
            }
            
            if index == currentPosition {
                segmentLabel.textColor = segmentTintColor
                segmentLabel.font = UIFont.systemFont(ofSize: segmentFontSize, weight: .bold)
            } else {
                segmentLabel.textColor = segmentDefaultColor
                segmentLabel.font = UIFont.systemFont(ofSize: segmentFontSize, weight: .medium)
            }
        }
    }
    
    func addSegment(title: String) {
        let newSegmentLabel = UILabel()
        newSegmentLabel.text = title
        newSegmentLabel.font = UIFont.systemFont(ofSize: segmentFontSize)
        segmentedStackView.addArrangedSubview(newSegmentLabel)
    }
    
    func insertSegment(title: String, at: Int) {
        let newSegmentLabel = UILabel()
        newSegmentLabel.text = title
        newSegmentLabel.font = UIFont.systemFont(ofSize: segmentFontSize)
        segmentedStackView.insertSubview(newSegmentLabel, at: at)
    }
    
    @objc
    func didTapSegmentendControl(_ sender: UITapGestureRecognizer) {
        let tapPosition = sender.location(in: self)
        
        for (index, segment) in segmentedStackView.arrangedSubviews.enumerated() {
            if segment.isInBound(point: tapPosition) {
                currentPosition = index
                changeIndicatorPosition()
                delegate?.BISegmentedControl?(didSelectSegmentAt: index)
                return
            }
        }
    }
}

extension UIView {
    func isInBound(point: CGPoint) -> Bool {
        return isInWidthBound(point: point) && isInHeightBound(point: point)
    }
    
    func isInWidthBound(point: CGPoint) -> Bool {
        return self.leftX <= point.x && point.x <= self.rightX
    }
    
    func isInHeightBound(point: CGPoint) -> Bool {
        return self.topY <= point.y && point.y <= self.bottomY
    }
    
    var topY: CGFloat {
        return self.frame.origin.y
    }
    
    var leftX: CGFloat {
        return self.frame.origin.x
    }
    
    var rightX: CGFloat {
        return self.frame.origin.x + self.frame.width
    }
    
    var bottomY: CGFloat {
        return self.frame.origin.y + self.frame.height
    }
}
