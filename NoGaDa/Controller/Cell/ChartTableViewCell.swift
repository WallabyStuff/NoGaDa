//
//  ChartTableViewCell.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/18.
//

import UIKit

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var chartNumberLabel: UILabel!
    @IBOutlet weak var chartNumberBoxView: UIView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellContentView.layer.borderColor = ColorSet.updatedSongCellStrokeColor.cgColor
    }

    private func initView() {
        cellContentView.clipsToBounds = false
        cellContentView.layer.borderWidth = 1
        cellContentView.layer.borderColor = ColorSet.updatedSongCellStrokeColor.cgColor
        cellContentView.layer.cornerRadius = 12
        
        chartNumberBoxView.layer.cornerRadius = 8
        chartNumberLabel.text   = ""
        songTitleLabel.text     = ""
        singerLabel.text        = ""
        chartNumberLabel.text   = ""
    }
}
