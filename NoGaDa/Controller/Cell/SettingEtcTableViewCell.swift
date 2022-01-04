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
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    // MARK: - Initialization
    private func initView() {
        titleLabel.text = ""
        iconBoxView.layer.cornerRadius = 12
        iconImageView.image = UIImage()
    }
}
