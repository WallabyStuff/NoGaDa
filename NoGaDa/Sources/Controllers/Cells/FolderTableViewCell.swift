//
//  FolderTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class FolderTableViewCell: UITableViewCell {
  
  
  // MARK: - Properties
  
  static let identifier = R.reuseIdentifier.folderTableViewCell.identifier
  
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
    
    cellContentView.layer.borderColor = R.color.lineBasic()!.cgColor
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    cellContentView.layer.borderWidth = 1
    cellContentView.layer.borderColor = R.color.lineBasic()!.cgColor
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
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.cellContentView.backgroundColor = R.color.backgroundBasicSelected()
      self.cellContentView.scaleDown()
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.cellContentView.backgroundColor = R.color.backgroundSecondary()
      self.cellContentView.releaseScale()
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    UIView.animate(withDuration: releaseAnimationDuration) {
      self.cellContentView.backgroundColor = R.color.backgroundSecondary()
      self.cellContentView.releaseScale()
    }
  }
}
