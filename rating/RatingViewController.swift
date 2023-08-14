//
//  RatingViewController.swift
//  servipedia
//
//

import UIKit
import RealmSwift
import FirebaseCrashlytics

class RatingViewController: UIViewController, UITableViewDataSource, ReseniaItemProtocol {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var oneStarB: UIButton!
    @IBOutlet weak var twoStarB: UIButton!
    @IBOutlet weak var threeStarB: UIButton!
    @IBOutlet weak var fourStarB: UIButton!
    @IBOutlet weak var fiveStarB: UIButton!
    @IBOutlet weak var sendReseniaB: UIButton!
    @IBOutlet weak var comentarioText: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var comentWarn: UIImageView!
    @IBOutlet weak var starWarn: UIImageView!
    var votes: Array<String> = []
    var reseniasList: Array<ReseniaModel> = []
    var user: String?
    var reseniaStars = 0
    var isKeyboardShowing = false
    var serviId: String?
    var delegate: RatingProtocol?
    var listPosition: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("RatingViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let u = self.user {
            self.ratingView.isHidden = false
            self.loginLabel.isHidden = true
                self.votes.forEach({
                    individualVote in
                    if let resenia = stringToResenia(vote: individualVote) {
                        self.reseniasList.append(resenia)
                        if (resenia.idUser == u) {
                            self.ratingView.isHidden = true
                            self.loginLabel.text = "YA HA CALIFICADO ESTE SERVICIO"
                            self.loginLabel.isHidden = false
                        }
                    }
                })
                self.tableView.register(UINib(nibName: "RatingViewCell", bundle: nil), forCellReuseIdentifier: "RatingTableViewCell")
                self.tableView.dataSource = self
        } else {
            self.votes.forEach({
                individualVote in
                if let resenia = stringToResenia(vote: individualVote) {
                    self.reseniasList.append(resenia)
                }
            })
            self.ratingView.isHidden = true
            self.loginLabel.text = "INICIE SESION PARA CALIFICAR ESTE SERVICIO"
            self.loginLabel.isHidden = false
            self.tableView.register(UINib(nibName: "RatingViewCell", bundle: nil), forCellReuseIdentifier: "RatingTableViewCell")
            self.tableView.dataSource = self
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlay(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidAppear() {
        isKeyboardShowing = true
    }

    @objc func keyboardDidDisappear() {
        isKeyboardShowing = false
    }
    
    @objc func didTapOverlay(_ sender : UITapGestureRecognizer) {
        if (isKeyboardShowing) {
            view.endEditing(true)
        } else {
            NotificationCenter.default.removeObserver(self)
            dismiss(animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reseniasList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingViewCell
        cell.configure(with: self.reseniasList[indexPath.row])
        cell.positionVotes = indexPath.row
        cell.delegate = self
        return cell
    }
    
    @IBAction func markOne(_ sender: Any) {
        self.reseniaStars = 1
        self.oneStarB.tintColor = UIColor.systemYellow
        self.twoStarB.tintColor = UIColor.darkGray
        self.threeStarB.tintColor = UIColor.darkGray
        self.fourStarB.tintColor = UIColor.darkGray
        self.fiveStarB.tintColor = UIColor.darkGray
    }
    
    @IBAction func markTwo(_ sender: Any) {
        self.reseniaStars = 2
        self.oneStarB.tintColor = UIColor.systemYellow
        self.twoStarB.tintColor = UIColor.systemYellow
        self.threeStarB.tintColor = UIColor.darkGray
        self.fourStarB.tintColor = UIColor.darkGray
        self.fiveStarB.tintColor = UIColor.darkGray
    }
    
    @IBAction func markThree(_ sender: Any) {
        self.reseniaStars = 3
        self.oneStarB.tintColor = UIColor.systemYellow
        self.twoStarB.tintColor = UIColor.systemYellow
        self.threeStarB.tintColor = UIColor.systemYellow
        self.fourStarB.tintColor = UIColor.darkGray
        self.fiveStarB.tintColor = UIColor.darkGray
    }
    
    @IBAction func markFour(_ sender: Any) {
        self.reseniaStars = 4
        self.oneStarB.tintColor = UIColor.systemYellow
        self.twoStarB.tintColor = UIColor.systemYellow
        self.threeStarB.tintColor = UIColor.systemYellow
        self.fourStarB.tintColor = UIColor.systemYellow
        self.fiveStarB.tintColor = UIColor.darkGray
    }
    
    @IBAction func markVFive(_ sender: Any) {
        self.reseniaStars = 5
        self.oneStarB.tintColor = UIColor.systemYellow
        self.twoStarB.tintColor = UIColor.systemYellow
        self.threeStarB.tintColor = UIColor.systemYellow
        self.fourStarB.tintColor = UIColor.systemYellow
        self.fiveStarB.tintColor = UIColor.systemYellow
    }
    
    @IBAction func sendResenia(_ sender: Any) {
        self.view.makeToastActivity()
        self.sendReseniaB.isEnabled = false
        view.endEditing(true)
        if validate() {
            let aux : String = "{\"valor\":\(String(reseniaStars)),\"comentario\":\"\(comentarioText.text ?? "")\",\"idUser\":\"\(user ?? "")\"}"
            
            self.delegate?.sendResenia(resenia: aux, valor: reseniaStars, serviId: self.serviId, positionItemList: self.listPosition, completionHandler: { success in
                if (success) {
                    if let resenia = self.stringToResenia(vote: aux) {
                        self.reseniasList.append(resenia)
                        self.tableView.reloadData()
                    }
                    self.sendReseniaB.isEnabled = false
                    self.ratingView.isHidden = true
                    self.loginLabel.text = "YA HA CALIFICADO ESTE SERVICIO"
                    self.loginLabel.isHidden = false
                    self.view.hideToastActivity()
                } else {
                    self.view.servipediaToast("Error al envíar la reseña")
                    self.dismiss(animated: true)
                }
            })
        } else {
            self.sendReseniaB.isEnabled = true
            self.view.hideToastActivity()
        }
    }
    func stringToResenia(vote: String) -> ReseniaModel? {
        let jsonData = Data(vote.utf8)
        do {
            let decodedObject = try JSONDecoder().decode(ReseniaModel.self, from: jsonData)
            decodedObject.isOwn = decodedObject.idUser == (user ?? "")
            return decodedObject
        } catch {
            self.view.servipediaToast("Ha ocurrido un error")
            return nil
        }
        
    }
    
    func deleteResenia(vote: ReseniaModel, positionVotes: Int) {
        self.view.makeToastActivity()
       delegate?.deleteResenia(resenia: vote, serviId: serviId, positionItemList: listPosition, positionVotesList: positionVotes, completionHandler: { success in
           if (success) {
            self.reseniasList.remove(at: positionVotes)
            self.tableView.reloadData()
            self.ratingView.isHidden = false
            self.loginLabel.isHidden = true
            self.sendReseniaB.isEnabled = true
            self.view.hideToastActivity()
           }
       })
    }
    
    func validate() -> Bool {
        var valid = true
        if let txt = comentarioText.text {
            if txt.count < 10 {
                comentWarn.isHidden = false
                valid = false
            } else {
                comentWarn.isHidden = true
            }
        }
        
        if reseniaStars != 0 {
            starWarn.isHidden = true
        } else {
            starWarn.isHidden = false
            valid = false
        }
        return valid
    }
}

protocol RatingProtocol {
    func sendResenia(resenia: String, valor: Int?, serviId: String?, positionItemList: Int?, completionHandler: @escaping CompletionHandler)
    func deleteResenia(resenia: ReseniaModel, serviId:String?, positionItemList: Int?, positionVotesList: Int?, completionHandler: @escaping CompletionHandler)
}

typealias CompletionHandler = (_ success: Bool) -> Void
