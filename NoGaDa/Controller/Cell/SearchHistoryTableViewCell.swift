//
//  SearchHistoryTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/10.
//

import UIKit
import RxSwift
import RxCocoa

class SearchHistoryTableViewCell: UITableViewCell {
    
    // MARK: - Declaration
    private var disposeBag = DisposeBag()
    var removeButtonTapAction: () -> Void = {}
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        initEventListener()
    }

    // MARK: - Initialization
    private func initView() {
        titleLabel.text = ""
        selectionStyle = .none
    }
    
    private func initEventListener() {
        removeButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.removeButtonTapAction()
            }).disposed(by: disposeBag)
    }
}

extension SearchHistoryTableViewCell {
    
    private var releaseAnimationDuration: CGFloat {
        return 0.3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        backgroundColor = ColorSet.songCellSelectedBackgroundColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: releaseAnimationDuration) {
            self.backgroundColor = ColorSet.backgroundColor
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: releaseAnimationDuration) {
            self.backgroundColor = ColorSet.backgroundColor
        }
    }
}
