//
//  SongOptionTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import UIKit

class PopUpSongOptionTableViewCell: UITableViewCell {

    // MARK: - Declaration
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    // MARK: - Initialization
    private func initView() {
        titleLabel.text = ""
        iconImageView.image = UIImage()
        
        let selectionView = UIView(frame: self.bounds)
        selectionView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
        selectedBackgroundView = selectionView
    }
}
