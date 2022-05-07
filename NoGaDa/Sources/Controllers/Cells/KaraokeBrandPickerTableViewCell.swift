//
//  KaraokeBrandPickerTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/01/06.
//

import UIKit

class KaraokeBrandPickerTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    @IBOutlet weak var brandNameLabel: UILabel!
    static let identifier = "karaokeBrandTableCell"
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    
    // MARK: - Initializers
    
    private func setupView() {
        brandNameLabel.text = ""
        
        let selectedView = UIView()
        selectedView.bounds = bounds
        selectedView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedBackgroundView = selectedView
    }
}
