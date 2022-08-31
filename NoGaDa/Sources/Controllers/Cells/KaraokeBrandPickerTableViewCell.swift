//
//  KaraokeBrandPickerTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/01/06.
//

import UIKit

class KaraokeBrandPickerTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.karaokeBrandTableCell.identifier
  @IBOutlet weak var brandNameLabel: UILabel!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    brandNameLabel.text = ""
    
    let selectedView = UIView()
    selectedView.bounds = bounds
    selectedView.backgroundColor = R.color.songCellSelectedBackgroundColor()
    selectedBackgroundView = selectedView
  }
}
