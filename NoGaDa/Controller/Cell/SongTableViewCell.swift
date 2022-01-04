//
//  SearchResultTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    // MARK: - Declaration
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailPlaceholderImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var songNumberLabel: UILabel!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.releaseAccentColor(with: ColorSet.textColor)
        singerLabel.releaseAccentColor(with: ColorSet.subTextColor)
    }

    // MARK: - Initialization
    private func initView() {
        thumbnailImageView.layer.cornerRadius = 16
        
        songNumberLabel.text    = ""
        titleLabel.text         = ""
        singerLabel.text        = ""
        
        let selectedView = UIView()
        selectedView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedView.layer.cornerRadius = 12
        selectedBackgroundView = selectedView
    }
}
