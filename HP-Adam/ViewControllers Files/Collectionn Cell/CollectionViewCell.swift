//
//  CollectionViewCell.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 04/04/2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var objectLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    static let identifier = "CollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CollectionViewCell", bundle: nil)
    }
    
    public func configure(with model: Model) {
        self.objectLabel.text = model.text
        self.objectLabel.textColor = .black
    }
}
