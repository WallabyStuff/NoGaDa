//
//  PopUpArchiveFolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

class PopUpArchiveFolderTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.popUpArchiveTableCell.identifier
  
  @IBOutlet weak var emojiLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupview()
  }
  
  
  // MARK: - Setups
  
  private func setupview() {
    // Selection View
    let selectionView = UIView(frame: self.frame)
    selectionView.layer.cornerRadius = 8
    selectionView.backgroundColor = R.color.popUpArchiveSeparatorColor()!
    self.selectedBackgroundView = selectionView
  }
}
