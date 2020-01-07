//
//  VideoTableViewCell.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 7.01.2020.
//  Copyright © 2020 Rapsodo Mobile 6. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ppImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var model: VideoTableCellModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUI() {
        self.ppImage.layer.cornerRadius = 25.0
        self.ppImage.layer.masksToBounds = true
        self.ppImage.clipsToBounds = true
    }
    
    func initCell(with model: VideoTableCellModel) {
        self.title.text = model.title
        self.subtitle.text = model.subtitle
        self.ppImage.image = model.pp
    }
}

struct VideoTableCellModel {
    var pp: UIImage?
    var title: String
    var subtitle: String
}
