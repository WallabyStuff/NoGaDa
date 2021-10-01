//
//  SearchFilterTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

class SearchFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    private func initView() {
        titleLabel.text = ""
        filterSwitch.isOn = true
    }
}
