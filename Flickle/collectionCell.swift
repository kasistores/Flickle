//
//  collectionCell.swift
//  Flickle
//
//  Created by Kevin Asistores on 1/23/16.
//  Copyright © 2016 Kevin Asistores. All rights reserved.
//

import UIKit

class collectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //@IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
