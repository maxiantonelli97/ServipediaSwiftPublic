//
//  ServiItemViewCell.swift
//  servipedia
//
//

import UIKit
import RealmSwift

protocol ServiItemViewCellDelegate: AnyObject {
    func clickPhone(with phone: String)
    func clickMap(whth address: String)
    func clickMapLyL(with latitud: String, longitud: String, name: String)
    func clickInsta(with insta: String)
    func whatsApp(with wsp: String)
    func setFavorito(with addFavorito: Bool, servi: ServiceItemModel, position: Int)
    func resenia(with votes: Array<String>, serviId: String, position: Int?)
}

class ServiItemViewCell: UITableViewCell {
    
    @IBOutlet weak var cornerV: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bPhone: UIButton!
    @IBOutlet weak var bWsp: UIButton!
    @IBOutlet weak var bMap: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var bInsta: UIButton!
    @IBOutlet weak var bStar: UIButton!
    @IBOutlet weak var bFav: UIButton!

    weak var delegate: ServiItemViewCellDelegate?
    private var servi = ServiceItemModel()
    var position: Int?
    let realm = try! Realm()
    
    func configure(with servi: ServiceItemModel, position: Int?, isLog: Bool, isFavSecc: Bool) {
        self.servi = servi
        self.position = position
        bFav.isHidden = !isLog
        bFav.isEnabled = isLog
        cornerV.layer.cornerRadius = 10
        ratingLabel.isHidden = isFavSecc
        bStar.isHidden = isFavSecc
        bStar.isEnabled = !isFavSecc
        
        if (isLog && (servi.favorite ?? false)) {
            bFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else if (!(servi.favorite ?? true)) {
            bFav.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        if (isFavSecc) {
            self.servi.favorite = true
            bFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
        self.nameLabel.text = servi.name
        self.descLabel.text = servi.desc ?? "Sin descripción"
        self.addressLabel.text = servi.address ?? "Sin dirección"
        if let r = servi.rating {
            let aux = String(format: "%.2f", r)
            self.ratingLabel.text = String(describing: aux)
        } else {
            self.ratingLabel.text = "0"
        }
        self.bWsp.setImage(UIImage(named: "wsp-disabled"), for: .disabled)
        self.bInsta.setImage(UIImage(named: "insta-disabled"), for: .disabled)
        self.bMap.setImage(UIImage(named: "map-disabled"), for: .disabled)
        self.bPhone.setImage(UIImage(named: "phone-disabled"), for: .disabled)
        self.bWsp.setImage(UIImage(named: "wsp"), for: .normal)
        self.bInsta.setImage(UIImage(named: "insta"), for: .normal)
        self.bMap.setImage(UIImage(named: "map"), for: .normal)
        self.bPhone.setImage(UIImage(named: "phone"), for: .normal)
        self.bPhone.isEnabled = servi.phone != nil
        self.bWsp.isEnabled = servi.wsp != nil
        self.bMap.isEnabled = servi.mapLink != nil || (servi.latitud != nil && servi.longitud != nil)
        self.bInsta.isEnabled = servi.instagramLink != nil
    }
    
    @IBAction func phoneClick(_ sender: Any) {
        if let p = self.servi.phone {
            delegate?.clickPhone(with: p)
        }
    }
    
    @IBAction func wspClick(_ sender: Any) {
        if let w = self.servi.wsp {
            delegate?.whatsApp(with: w)
        }
    }
    
    @IBAction func instaClick(_ sender: Any) {
        if let i = self.servi.instagramLink {
            delegate?.clickInsta(with: i)
        }
    }
    
    @IBAction func mapClick(_ sender: Any) {
        if let m = self.servi.mapLink {
            delegate?.clickMap(whth: m)
        } else if let lat = self.servi.latitud, let long = self.servi.longitud, let n = self.servi.name{
            delegate?.clickMapLyL(with: lat, longitud: long, name: n)
        }
    }
    
    @IBAction func favClick(_ sender: Any) {
        if let fav = self.servi.favorite{
            if fav {
                bFav.setImage(UIImage(systemName: "heart"), for: .normal)
                delegate?.setFavorito(with: false, servi: self.servi, position: self.position ?? -1)
            } else {
                bFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                delegate?.setFavorito(with: true, servi: self.servi, position: self.position ?? -1)
            }
            self.servi.favorite = !fav
        }
    }
    
    
    @IBAction func starClick(_ sender: Any) {
        delegate?.resenia(with: self.servi.votes, serviId: self.servi.id!, position: self.position)
    }
}
