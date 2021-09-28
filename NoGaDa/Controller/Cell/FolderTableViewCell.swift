//
//  FolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var titleEmojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellContentView.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
    }

    private func initView() {
        cellContentView.layer.borderWidth = 1
        cellContentView.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
        cellContentView.layer.cornerRadius = 12
        titleEmojiLabel.text    = ""
        titleLabel.text         = ""
    }
}
