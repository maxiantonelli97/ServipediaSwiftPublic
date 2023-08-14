//
//  RubroViewCell.swift
//  servipedia
//
//

import UIKit

class RubroViewCell: UITableViewCell {

    @IBOutlet weak var rubro: UILabel!
    var rubroText: String?
    
    func configure(whit r: String) {
        rubro.text = r
        rubroText = r
    }
}
