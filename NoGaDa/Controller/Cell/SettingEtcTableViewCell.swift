//
//  SettingEtcTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit

class SettingEtcTableViewCell: UITableViewCell {

    // MARK: - Declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconBoxView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }

    // MARK: - Initializers
    private func setupView() {
        titleLabel.text = ""
        iconBoxView.layer.cornerRadius = 12
        iconImageView.image = UIImage()
        
        let selectedView = UIView()
        selectedView.bounds = bounds
        selectedView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedBackgroundView = selectedView
    }
}
