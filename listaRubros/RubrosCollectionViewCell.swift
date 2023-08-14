//
//  RubrosCollectionViewCell.swift
//  servipedia
//
//  Created by Desarrollo Mac 1 on 24/07/2023.
//

import UIKit

class RubrosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var cornerV: UIStackView!
    @IBOutlet weak var textV: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerV.layer.cornerRadius = 10
    }
    
    func configure(r: String, i: String?) {
        textV.text = r
        if let im = i,
            let data = Data(base64Encoded: im, options: .ignoreUnknownCharacters) {
            imageV.image = UIImage(data: data)
        } else {
            imageV.image = UIImage(systemName: "multiply")
        }
    }

}
