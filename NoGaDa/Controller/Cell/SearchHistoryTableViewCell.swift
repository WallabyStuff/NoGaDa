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
    var disposeBag = DisposeBag()
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
        
        let selectedView = UIView()
        selectedView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedBackgroundView = selectedView
    }
    
    private func initEventListener() {
        removeButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.removeButtonTapAction()
            }).disposed(by: disposeBag)
    }
}
