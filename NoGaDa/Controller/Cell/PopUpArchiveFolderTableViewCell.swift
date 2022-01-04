//
//  PopUpArchiveFolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

class PopUpArchiveFolderTableViewCell: UITableViewCell {

    // MARK: - Declaration
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }

    // MARK: - Initialization
    func initView() {
        // Selection View
        let selectionView = UIView(frame: self.frame)
        selectionView.layer.cornerRadius = 8
        selectionView.backgroundColor = ColorSet.popUpArchiveSeparatorColor
        self.selectedBackgroundView = selectionView
    }
}
