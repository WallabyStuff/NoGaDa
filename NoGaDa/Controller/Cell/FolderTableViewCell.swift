//
//  FolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    private func initView() {
        cellContentView.layer.cornerRadius = 12
    }
}
