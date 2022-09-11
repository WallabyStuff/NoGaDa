//
//  SearchResultTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class SongTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.searchResultTableViewCell.identifier
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var thumbnailPlaceholderImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var singerLabel: UILabel!
  @IBOutlet weak var songNumberLabel: UILabel!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.releaseAccentColor(with: R.color.textBasic()!)
    singerLabel.releaseAccentColor(with: R.color.textSecondary()!)
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    thumbnailImageView.layer.cornerRadius = 16
    
    songNumberLabel.text    = ""
    titleLabel.text         = ""
    singerLabel.text        = ""
    
    let selectedView = UIView()
    selectedView.backgroundColor = R.color.backgroundBasicSelected()
    selectedView.layer.cornerRadius = 20
    selectedBackgroundView = selectedView
  }
}
