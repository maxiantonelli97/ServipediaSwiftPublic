//
//  ViewControllerLista.swift
//  servipedia
//
//

import UIKit
import FirebaseFirestore
import RealmSwift
import FirebaseCrashlytics

class ListaViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var servisList: Array<ServiceItemModel> = []
    private let db = Firestore.firestore()
    var favmodel: FavoritosModel?
    let realm = try! Realm()
    var usuarioLogueado: UserModel?
    var serviSelectId: String?
    
    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("ListaViewController")
        tableView.isHidden = true
        let aux = realm.objects(UserModel.self)
        usuarioLogueado = aux.first
            self.tableView.register(UINib(nibName: "ServiItemViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
            self.tableView.dataSource = self
            self.tableView.reloadData()
        tableView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servisList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! ServiItemViewCell
        cell.configure(with: self.servisList[indexPath.row], position: indexPath.row, isLog: self.usuarioLogueado?.userId != nil, isFavSecc: false)
        cell.delegate = self
        return cell
    }
}

extension ListaViewController: RatingProtocol {
    func sendResenia(resenia: String, valor: Int?, serviId: String?, positionItemList: Int?, completionHandler: @escaping (Bool) -> Void) {
        if let pos = positionItemList, // Posision del servicio en la lista
           let valor = valor, // Valor del nuevo voto
           let anterior = self.servisList[pos].rating { // Rating que tenía anteriormente
                let auxRat: Double = mathNewResenia(cantVotos: self.servisList[pos].votes.count,
                                                   ratAnterior: anterior,
                                                   givenRating: valor)  // Obtengo el nuevo rating
                let auxUpdate = ["votes": FieldValue.arrayUnion([resenia]), // Agrego la reseña al arreglo de votes en Firebase
                              "rating": auxRat] as [String : Any]           // Asigno el nuevo rating al valor rating en Firebase
                db.collection("services").document(serviId!).updateData(auxUpdate) {
                    err in
                    completionHandler(err == nil)       // Se envio el nuevo rating EN fiREBASE. Actualizo la vista inferior
                }
            try! realm.write {
                self.servisList[pos].rating = auxRat    //Actualizo el rating en el servicio de la app
                self.servisList[pos].votes.append(resenia)  //Agrego el nuevo ratint en el servicio de la app
            }
            self.tableView.reloadData()
        } else {
            //No se puedo envíar la reseña
        }
    }
    
    func deleteResenia(resenia: ReseniaModel, serviId: String?, positionItemList: Int?, positionVotesList: Int?, completionHandler: @escaping (Bool) -> Void) {
        if let userId = usuarioLogueado?.userId,
           let posList = positionItemList, // Posision del servicio en la lista
           let valor = resenia.valor, // Valor del voto eliminado
           let posVotes = positionVotesList, // Posision del voto en la lista de votos
           let anterior = self.servisList[posList].rating {  // Rating que tenía anteriormente
                let auxRes : String = "{\"valor\":\(String(resenia.valor!)),\"comentario\":\"\(resenia.comentario!)\",\"idUser\":\"\(userId)\"}"
                let auxRat: Double = mathRemoveResenia(cantVotos: self.servisList[posList].votes.count,
                                                   ratAnterior: anterior,
                                                   givenRating: valor)  // Obtengo el nuevo rating
                let auxUpdate = ["votes": FieldValue.arrayRemove([auxRes]), // Remuevo la reseña al arreglo de votes en Firebase
                              "rating": auxRat] as [String : Any] // Asigno el nuevo rating al valor rating en Firebase
                db.collection("services").document(serviId!).updateData(auxUpdate) {
                    err in
                    completionHandler(err == nil) // Se elimino el rating en fiREBASE. Actualizo la vista inferior
                }
            try! realm.write {
                self.servisList[posList].rating = auxRat    //Actualizo el rating en el servicio de la app
                self.servisList[posList].votes.remove(at: posVotes)  //Elimino el ratint en el servicio de la app
            }
            self.tableView.reloadData()
        } else {
            //No se puedo eliminar la reseña
        }
    }
    
    func mathNewResenia(cantVotos: Int, ratAnterior: Double, givenRating: Int) -> Double {
        return (((ratAnterior * Double(cantVotos)) + Double(givenRating)) / Double(cantVotos + 1))
    }
    
    func mathRemoveResenia(cantVotos: Int, ratAnterior: Double, givenRating: Int) -> Double {
        if (cantVotos == 1) {
            return 0
        } else {
            return (((ratAnterior * Double(cantVotos)) - Double(givenRating)) / Double(cantVotos - 1))
        }
    }
}

extension ListaViewController: ServiItemViewCellDelegate {
    func resenia(with  votes: Array<String>, serviId: String, position: Int?) {
        let vc = RatingViewController()
        vc.votes = votes
        vc.user = self.usuarioLogueado?.userId
        vc.delegate = self
        vc.serviId = serviId
        vc.listPosition = position
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
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

    func setFavorito(with addFavorito: Bool, servi: ServiceItemModel, position: Int) {
        if (addFavorito) {
            try! realm.write {
                self.favmodel?.lista.append(servi)
                realm.add(self.favmodel!, update: .modified)
            }
           } else {
            for (index, item) in favmodel!.lista.enumerated() {
                if (item.id == servisList[position].id) {
                    try! realm.write {
                        self.favmodel?.lista.remove(at: index)
                        realm.add(self.favmodel!, update: .modified)
                    }
                }
            }
        }
    }
}
