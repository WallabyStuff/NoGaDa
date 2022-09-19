//
//  PopUpArchiveFolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

class PopUpArchiveFolderTableViewCell: UITableViewCell {
  
  // MARK: - Constants
  
  static let identifier = R.reuseIdentifier.popUpArchiveTableCell.identifier
  
  struct Metric {
    static let selectedViewCornerRadius = 8.f
  }
  
  
  // MARK: - UI
  
  @IBOutlet weak var emojiLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupview()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    emojiLabel.text = ""
    titleLabel.text = ""
  }
  
  
  // MARK: - Setups
  
  private func setupview() {
    setupSelectedView()
  }
  
  private func setupSelectedView() {
    let selectionView = UIView(frame: self.frame)
    selectionView.layer.cornerRadius = Metric.selectedViewCornerRadius
    selectionView.backgroundColor = R.color.accentYellowDark()!
    self.selectedBackgroundView = selectionView
  }
}
