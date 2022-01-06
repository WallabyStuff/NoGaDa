//
//  SearchFilterTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

class SearchFilterTableViewCell: UITableViewCell {

    // MARK: - Delcaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    // MARK: - Initialization
    private func initView() {
        titleLabel.text = ""
        filterSwitch.isOn = true
        selectionStyle = .none
    }
}
