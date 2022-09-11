//
//  ChartTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/18.
//

import UIKit

class UpdatedSongTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.updatedSongTableViewCell.identifier
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var thumbnailPlaceholderImageView: UIImageView!
  @IBOutlet weak var songTitleLabel: UILabel!
  @IBOutlet weak var singerLabel: UILabel!
  @IBOutlet weak var songNumberLabel: UILabel!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  
  // MARK: - Initializers
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    thumbnailImageView.layer.cornerRadius = 12
    
    songTitleLabel.text     = ""
    singerLabel.text        = ""
    songNumberLabel.text    = ""
    
    let selectedView = UIView()
    selectedView.backgroundColor = R.color.backgroundBasicSelected()!
    selectedView.layer.cornerRadius = 12
    selectedBackgroundView = selectedView
  }
}
