//
//  SearchFilterTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

class SearchFilterTableViewCell: UITableViewCell {
  
  // MARK: - Cosntants
  
  static let identifier = R.reuseIdentifier.searchFilterTableCell.identifier
  
  
  // MARK: - UI
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var filterSwitch: UISwitch!
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.text = ""
    filterSwitch.isOn = true
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    selectionStyle = .none
  }
}
