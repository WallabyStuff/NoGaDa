//
//  SettingEtcTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa

class SettingItemTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.settingEtcTableCell.identifier
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var iconContainerView: UIView!
  @IBOutlet weak var iconImageView: UIImageView!

  private var disposeBag = DisposeBag()
  var itemSelectAction: () -> Void = {}
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  override func prepareForReuse() {
    titleLabel.text = ""
    iconImageView.image = nil
    itemSelectAction = {}
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    setupIconContainerView()
    setupSelectedView()
    setupAction()
  }
  
  private func setupIconContainerView() {
    iconContainerView.layer.cornerRadius = 12
  }
  
  private func setupSelectedView() {
    let selectedView = UIView()
    selectedView.bounds = bounds
    selectedView.backgroundColor = R.color.backgroundBasicSelected()!
    selectedView.layer.cornerRadius = 12
    selectedBackgroundView = selectedView
  }

  private func setupAction() {
    self.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { strongSelf, _ in
        strongSelf.itemSelectAction()
      }).disposed(by: disposeBag)
  }
  
  
  // MARK: - Methods
  
  func configure(item: SettingItem) {
    titleLabel.text = item.title
    iconImageView.image = item.icon
    iconContainerView.backgroundColor = item.iconContainerColor
  }
}
