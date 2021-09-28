//
//  SearchResultTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellContentview: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var songNumberBoxView: UIView!
    @IBOutlet weak var songNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    private func initView() {
        contentView.clipsToBounds = false
        
        cellContentview.layer.borderWidth = 1
        cellContentview.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
        cellContentview.layer.cornerRadius = 12
        cellContentview.clipsToBounds = false
        
        songNumberBoxView.layer.cornerRadius = 12
        songNumberBoxView.layer.masksToBounds = true
        songNumberBoxView.layer.borderWidth = 1
        songNumberBoxView.layer.borderColor = ColorSet.songCellNumberBoxStrokeColor.cgColor
        songNumberBoxView.clipsToBounds = false
        songNumberBoxView.setSongNumberBoxShadow()
        
        songNumberLabel.text    = ""
        titleLabel.text         = ""
        singerLabel.text        = ""
        brandLabel.text         = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellContentview.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
        singerLabel.releaseAccentColor()
        titleLabel.releaseAccentColor()
    }
}
