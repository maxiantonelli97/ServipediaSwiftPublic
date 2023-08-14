//
//  RatingViewCell.swift
//  servipedia
//

import UIKit
import FirebaseCrashlytics

class RatingViewCell: UITableViewCell {

    @IBOutlet weak var trashB: UIButton!
    @IBOutlet weak var ratingText: UITextView!
    @IBOutlet weak var commentText: UITextView!
    var vote: ReseniaModel?
    var positionVotes: Int?
    var delegate: ReseniaItemProtocol?
    
    func configure(with vote: ReseniaModel) {
        Crashlytics.crashlytics().log("RatingViewCell")
        self.vote = vote
        ratingText.text = String(vote.valor!)
        commentText.text = vote.comentario
        if let own = vote.isOwn {
            trashB.isHidden = !own
        }
    }
    
    @IBAction func deleteResenia(_ sender: Any) {
        if let pv = positionVotes {
            trashB.isEnabled = false
            delegate?.deleteResenia(vote: vote!, positionVotes: pv)
        }
    }
}

protocol ReseniaItemProtocol {
    func deleteResenia(vote: ReseniaModel, positionVotes: Int)
}

