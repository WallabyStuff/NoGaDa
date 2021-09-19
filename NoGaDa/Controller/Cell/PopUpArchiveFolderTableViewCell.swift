//
//  PopUpArchiveFolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

class PopUpArchiveFolderTableViewCell: UITableViewCell {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    func initView() {
        // Selection View
        let selectionView = UIView(frame: self.frame)
        selectionView.layer.cornerRadius = 8
        selectionView.backgroundColor = ColorSet.accentSubColor
        self.selectedBackgroundView = selectionView
    }
}
