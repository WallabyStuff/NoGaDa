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
  
  // MARK: - Constants
  
  static let identifier = R.reuseIdentifier.searchHistoryTableCell.identifier
  
  struct Metric {
    static let tapReleaseAnimationDuration = 0.2.f
  }
  
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  public var removeButtonTapAction: () -> Void = {}
  
  
  // MARK: - UI
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var removeButton: UIButton!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    bind()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.text = ""
    selectionStyle = .none
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    removeButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.removeButtonTapAction()
      }).disposed(by: disposeBag)
  }
}


// MARK: - Tap Aniamtions

extension SearchHistoryTableViewCell {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    backgroundColor = R.color.backgroundBasicSelected()!
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    self.backgroundColor = R.color.backgroundBasic()!
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    UIView.animate(withDuration: Metric.tapReleaseAnimationDuration) {
      self.backgroundColor = R.color.backgroundBasic()!
    }
  }
}
