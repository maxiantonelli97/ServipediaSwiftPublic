//
//  BuscadorViewController.swift
//  servipedia
//
//

import UIKit
import FirebaseFirestore
import RealmSwift
import FirebaseCrashlytics

class BuscadorViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var reloadB: UIButton!
    
    var rubrosList: Array<RubroModel> = []
    var rubrosListOriginal: Array<RubroModel> = []
    private let db = Firestore.firestore()
    var rubroSel: RubroModel?
    var servisList: Array<ServiceItemModel> = []
    let realm = try! Realm()
    var usuarioLogueado: UserModel?
    var favmodel: FavoritosModel?
    
    private var sizeTable = UIScreen.main.bounds.width / 2
    
    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("BuscadorViewController")
        let aux = realm.objects(UserModel.self)
        usuarioLogueado = aux.first
    }
    
    override func viewDidLoad() {
        self.getRubros()
    }
    
    func getRubros() {
        self.view.makeToastActivity()
        if (Reachability.hayInternet()) {
            db.collection("rubros").order(by: "name")
                .getDocuments() { (querySnapshot, err) in
                    if (err != nil) {
                        self.view.servipediaToast("Ocurrió un error al obtener los rubros")
                        self.hayRubros(hay: false)
                    } else {
                        for document in querySnapshot!.documents {
                            self.rubrosList.append(
                                RubroModel(
                                    id: document.get("id") as! String,
                                    name: document.get("name") as! String,
                                    image: document.get("image") as? String
                                )
                            )
                        }
                        self.rubrosListOriginal = self.rubrosList
                        self.hayRubros(hay: true)
                        self.collectionView.dataSource = self
                        self.collectionView.delegate = self
                        self.collectionView.register(UINib(nibName: "RubrosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RubrosItemViewCell")
                        self.collectionView.reloadData()
                    }
            }
        } else {
            self.view.servipediaToast("Asegurese de estar conectado a internet")
            hayRubros(hay: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vcLista" {
            if let destino = segue.destination as? ListaViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Buscador"
                backItem.tintColor = UIColor.white
                navigationItem.backBarButtonItem = backItem
                destino.servisList = servisList
                destino.favmodel = favmodel
            }
        }
        self.view.hideToastActivity()
    }
    
    @objc func tableViewLabelClick(sender : UITapGestureRecognizer){
        self.view.makeToastActivity()
        let tapLocation = sender.location(in: collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: tapLocation)
        let position = indexPath?.row ?? 0
        self.rubroSel = rubrosList[position]
        buscar()
    }
    
    func buscar() {
        self.view.makeToastActivity()
        if (Reachability.hayInternet()) {
            if let n = self.rubroSel?.id {
                db.collection("services").whereField("rubros", arrayContains: n)
                .getDocuments()
                { (querySnapshot, err) in
                        if err != nil {
                            self.view.hideToastActivity()
                            self.view.servipediaToast("Ocurrio un error al obtener los servicios")
                        } else {
                            if querySnapshot!.documents.isEmpty {
                                self.view.servipediaToast("No hay servicios para el rubro seleccionado")
                                self.view.hideToastActivity()
                            } else {
                                var listaAux: Array<ServiceItemModel> = []
                                for document in querySnapshot!.documents {
                                    let rubroAux = List<String>()
                                    (document.get("rubros") as! Array<String>?)?.forEach{ r in
                                        rubroAux.append(r)
                                    }
                                    listaAux.append(
                                        ServiceItemModel(
                                            id: document.get("id") as? String,
                                            address: document.get("address") as? String,
                                            desc: document.get("desc") as? String,
                                            rubros: rubroAux,
                                            instagramLink: document.get("instagramLink") as? String,
                                            mapLink: document.get("mapLink") as? String,
                                            name: document.get("name") as? String,
                                            phone: document.get("phone") as? String,
                                            wsp: document.get("wsp") as? String,
                                            latitud: document.get("latitud") as? String,
                                            longitud: document.get("longitud") as? String,
                                            rating: document.get("rating") as? Double,
                                            votes: document.get("votes") as? Array<String> ?? [],
                                            favorite: false
                                        )
                                    )
                                }
                                self.servisList = listaAux
                                if (self.servisList.isEmpty) {
                                    self.view.servipediaToast("No hay servicios para el rubro seleccionado")
                                } else {
                                    self.obtenerFavoritos()
                                }
                            }
                    }
                }
            } else {
                // No hay rubro seleccionado
                self.view.hideToastActivity()
                self.view.servipediaToast("Ocurrio un error al obtener los servicios")
            }
        } else {
            // No hay internet
            self.view.hideToastActivity()
            self.view.servipediaToast("Asegurese de estar conectado a internet")
        }
    }
    
    private func obtenerFavoritos() {
        if let i = usuarioLogueado?.userId {
            self.favmodel = realm.objects(FavoritosModel.self).first(where: { fav in
                fav.userId == i
            }) ?? FavoritosModel(userId: i)
            self.favmodel?.lista.forEach { fav in
                self.servisList.forEach{servi in
                    if (servi.id == fav.id) {
                        servi.favorite = true
                    }
                }
            }
        }
        performSegue(withIdentifier: "vcLista", sender: nil)
    }

    private func hayRubros(hay: Bool) {
        self.reloadB.isHidden = hay
        self.collectionView.isHidden = !hay
        self.searchBarView.isHidden = !hay
        self.reloadB.isEnabled = !hay
        self.view.hideToastActivity()
    }
    
    @IBAction func recargarRubros(_ sender: Any) {
        self.reloadB.isEnabled = false
        getRubros()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.rubrosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RubrosItemViewCell", for: indexPath)as! RubrosCollectionViewCell
        cell.configure(r: self.rubrosList[indexPath.row].name, i: self.rubrosList[indexPath.row].image)
        let labelRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tableViewLabelClick))
        cell.addGestureRecognizer(labelRecognizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aux = CGSize(width: sizeTable, height: sizeTable)
        return aux
    }
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rubrosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! RubroViewCell
        cell.configure(whit: self.rubrosList[indexPath.row].name)
        let labelRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tableViewLabelClick))
        cell.addGestureRecognizer(labelRecognizer)
        return cell
    }*/
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            if (self.searchBarView.showsCancelButton) {
                self.searchBarView.resignFirstResponder()
            }
            self.rubrosList = self.rubrosListOriginal
        } else {
            self.rubrosList = self.rubrosListOriginal.filter { r in
                r.name.contains(searchText)
            }
        }
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarView.resignFirstResponder()
    }
}
