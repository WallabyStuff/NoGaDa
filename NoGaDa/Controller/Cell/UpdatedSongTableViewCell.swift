//
//  ChartTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/18.
//

import UIKit

class UpdatedSongTableViewCell: UITableViewCell {

    // MARK: - Declaration
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailPlaceholderImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var songNumberLabel: UILabel!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Initialization
    private func initView() {
        thumbnailImageView.layer.cornerRadius = 12
        
        songTitleLabel.text     = ""
        singerLabel.text        = ""
        songNumberLabel.text    = ""
        
        let selectedView = UIView()
        selectedView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedView.layer.cornerRadius = 12
        selectedBackgroundView = selectedView
    }
}
