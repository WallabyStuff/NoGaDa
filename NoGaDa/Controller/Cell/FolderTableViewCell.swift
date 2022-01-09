//
//  FolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    // MARK: - Declaration
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var titleEmojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    public static let releaseAnimationDuration: CGFloat = 0.5
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellContentView.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
    }

    // MARK: - Initializers
    private func setupView() {
        cellContentView.layer.borderWidth = 1
        cellContentView.layer.borderColor = ColorSet.songCellStrokeColor.cgColor
        cellContentView.layer.cornerRadius = 12
        
        titleEmojiLabel.text    = ""
        titleLabel.text         = ""
    }
}

// MARK: - Extensions
extension FolderTableViewCell {
    private var releaseAnimationDuration: CGFloat {
        return 0.2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        cellContentView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.cellContentView.backgroundColor = ColorSet.songCellBackgroundColor
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: releaseAnimationDuration) {
            self.cellContentView.backgroundColor = ColorSet.songCellBackgroundColor
        }
    }
}
