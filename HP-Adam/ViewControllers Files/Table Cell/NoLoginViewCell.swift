//
//  NoLoginViewCell.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 31/03/2021.
//

import UIKit

class NoLoginViewCell: UITableViewCell {

    @IBOutlet weak var collectionViewCell: UIView!
    
    static let identifier = "NoLoginViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "NoLoginViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Size of the collection view cell
    func collectionViewCell(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
}
