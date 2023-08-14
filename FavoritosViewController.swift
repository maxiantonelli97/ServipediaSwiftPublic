
//
//  FavoritosViewController.swift
//  servipedia
//
//

import UIKit
import FirebaseFirestore
import RealmSwift
import FirebaseCrashlytics

class FavoritosViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var noFav: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadB: UIButton!
    
    
    private let db = Firestore.firestore()
    var favmodel: FavoritosModel?
    let realm = try! Realm()
    var usuarioLogueado: UserModel?

    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("FavoritosViewController")
        buscarFavoritos()
    }
    
    @IBAction func recargarFavoritos(_ sender: Any) {
        self.reloadB.isEnabled = false
        buscarFavoritos()
    }
    
    private func buscarFavoritos() {
        self.view.makeToastActivity()
        let aux = realm.objects(UserModel.self)
        usuarioLogueado = aux.first
        if let i = usuarioLogueado?.userId {
            let favModelAux = realm.objects(FavoritosModel.self).first(where: { fav in
                fav.userId == i}) ?? FavoritosModel(userId: i)
                if (favModelAux.lista.isEmpty == true) {
                    mostrarVistaSegun(caso: 2)
                } else {
                    self.favmodel = favModelAux
                    self.tableView.register(UINib(nibName: "ServiItemViewCell", bundle: nil), forCellReuseIdentifier: "FavTableViewCell")
                    
                    self.tableView.dataSource = self
                    
                    self.tableView.reloadData()
                    
                    mostrarVistaSegun(caso: 1)
                }
        } else {
            mostrarVistaSegun(caso: 3)
        }
    }
    
    // caso 1: Mostrar tableView con favoritos
    // caso 2: Mostrar noFav porque no hay favoritos
    // caso 3 u otro: Mostrar reloadB para recargar por error
    private func mostrarVistaSegun(caso: Int) {
        switch caso {
        case 1: do {
            self.tableView.isHidden = false
            self.noFav.isHidden = true
            self.reloadB.isHidden = true
        }
        case 2: do {
            self.tableView.isHidden = true
            self.noFav.isHidden = false
            self.reloadB.isHidden = true
        }
        default: do {
            self.tableView.isHidden = true
            self.noFav.isHidden = true
            self.reloadB.isHidden = false
            self.reloadB.isEnabled = true
            self.view.servipediaToast("Ocurrió un error al obtener los favoritos")
        }
        }
        self.view.hideToastActivity()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favmodel!.lista.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavTableViewCell", for: indexPath) as! ServiItemViewCell
        cell.nameLabel.text = self.favmodel!.lista[indexPath.row].name
        cell.addressLabel.text = self.favmodel!.lista[indexPath.row].address
        cell.descLabel.text = self.favmodel!.lista[indexPath.row].description
        
        cell.configure(with: self.favmodel!.lista[indexPath.row], position: indexPath.row, isLog: true, isFavSecc: true)
        cell.delegate = self
        return cell
    }
}

extension FavoritosViewController: ServiItemViewCellDelegate {
    func resenia(with votes: Array<String>, serviId: String, position: Int?) {
        print("resenia")
    }
    
    func setFavorito(with addFavorito: Bool, servi: ServiceItemModel, position: Int) {
        if (position != -1 && usuarioLogueado != nil) {
            for (index, item) in favmodel!.lista.enumerated() {
                if (item.id == servi.id) {
                    try! realm.write {
                        self.favmodel!.lista.remove(at: index)
                        realm.add(self.favmodel!, update: .modified)
                    }
                }
            }
            self.tableView.reloadData()
            if (self.favmodel!.lista.count == 0) {
                self.tableView.isHidden = true
                self.noFav.isHidden = false
            }
        }
    }
    
    func clickMap(whth address: String) {
        Utils().openMap(map: address)
    }
    
    func clickMapLyL(with latitud: String, longitud: String, name: String) {
        if let lat = Double(latitud), let long = Double(longitud) {
            Utils().openMapLatLong(latitud: lat, longitud: long, name: name)
        }
    }
    
    func clickInsta(with insta: String) {
        Utils().openInstagram(insta: insta)
    }
    
    func whatsApp(with wsp: String) {
        Utils().sendWsp(phone: wsp)
    }
    
    func clickPhone(with phone: String) {
        Utils().callNumber(phoneNumber: phone)
    }
}
