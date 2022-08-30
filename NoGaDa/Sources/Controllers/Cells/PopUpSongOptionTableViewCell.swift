//
//  SongOptionTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import UIKit

class PopUpSongOptionTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.popUpSongOptionTableCell.identifier
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  
  // MARK: - Initializers
  
  private func setupView() {
    titleLabel.text = ""
    iconImageView.image = UIImage()
    
    let selectionView = UIView(frame: self.bounds)
    selectionView.backgroundColor = R.color.songCellSelectedBackgroundColor()
    selectedBackgroundView = selectionView
  }
}
