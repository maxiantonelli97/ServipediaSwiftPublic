//
//  MainNavController.swift
//  servipedia
//
//

import UIKit
import RealmSwift
import SwiftUI
import FirebaseCrashlytics
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

class MainNavController: UINavigationController {

    var logueado = false
    let realm = try! Realm()
    var usuarioLogueado: UserModel?
    private var currentNonce: String?
    private let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("MainNavController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aux = realm.objects(TermsModel.self)
        if let acepted = aux.first?.termsAcepted {
            if (acepted) {
                self.termsAcept()
            } else {
                self.mostrarDialog()
            }
        } else {
            self.mostrarDialog()
        }
    }
    
    private func mostrarDialog() {
        self.performSegue(withIdentifier: "showAlertDialog", sender: self)
    }
    
    func termsAcept() {
        self.viewControllers = []
        try! realm.write {
            realm.add(TermsModel(termsAcepted: true))
        }
        let aux = realm.objects(UserModel.self)
        self.usuarioLogueado = aux.first
            
        logueado = self.usuarioLogueado?.userId != nil
        
        self.performSegue(withIdentifier: "isLogueado", sender: self)
    }
    
    @objc func logInClick(sender: UITapGestureRecognizer) {
        self.view.makeToastActivity()
        currentNonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.requestedScopes = [.fullName]
        request.nonce = sha256(currentNonce!)
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    @objc func logOutClick(sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        actionSheet.addAction(accionCancelar)
        let accionEliminarCuenta = UIAlertAction(title: "Eliminar Cuenta",
                                                   style: .default) { _ in
                                                    self.dialogEliminarCuenta()
        }
        actionSheet.addAction(accionEliminarCuenta)
        let accionCerrarSesion = UIAlertAction(title: "Cerrar Sesión",
                                                style: .default) { _ in
                                                 self.dialogCerrarSesion()
        }
        actionSheet.addAction(accionCerrarSesion)
        let accionFavoritos = UIAlertAction(title: "Favoritos",
                                                style: .default) { _ in
                                                 self.favoritos()
        }
        actionSheet.addAction(accionFavoritos)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: 0, y: self.view.bounds.maxY, width: view.bounds.width, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func favoritos() {
        self.view.makeToastActivity()
        if let i = usuarioLogueado?.userId {
            let favModelAux = realm.objects(FavoritosModel.self).first(where: { fav in
                fav.userId == i}) ?? FavoritosModel(userId: i)
                if (favModelAux.lista.isEmpty == true) {
                    self.view.servipediaToast("No hay items agregados a favoritos")
                } else {
                    self.performSegue(withIdentifier: "goFavoritos", sender: self)
                    self.performSegue(withIdentifier: "isLogueado", sender: self)
                }
        } else {
            self.view.servipediaToast("Ocurrio un error al obtener los favoritos")
        }
        self.view.hideToastActivity()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "isLogueado" {
            if let destino = segue.destination as? UITabBarController {
                if logueado {
                    let right = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: nil, action: #selector(logOutClick))
                    right.tintColor = UIColor.white
                    destino.navigationItem.rightBarButtonItem = right
                } else {
                    let right = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: nil, action: #selector(logInClick))
                    right.tintColor = UIColor.white
                    destino.navigationItem.rightBarButtonItem = right
                }
                let left = UIBarButtonItem(title: "Servipedia", style: .plain, target: nil, action:  #selector(serviInstagram))
                left.tintColor = UIColor.white
                destino.navigationItem.leftBarButtonItem = left
                self.view.hideToastActivity()
            }
        }
    }
    
    private func dialogCerrarSesion() {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Esta seguro que desea cerrar sesión?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SI", style: .default, handler: { action in
            self.dismiss(animated: false)
            self.cerrarSesion()
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
            self.dismiss(animated: false)
        }))
        alert.modalPresentationStyle = .overCurrentContext
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dialogEliminarCuenta() {
        let alert = UIAlertController(title: "Eliminar Cuenta", message: "¿Esta seguro que desea eliminar su cuenta?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "SI", style: .default, handler: { action in
            self.dismiss(animated: false)
            self.eliminarCuenta()
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { action in
            self.dismiss(animated: false)
        }))
        alert.modalPresentationStyle = .overCurrentContext
        self.present(alert, animated: true, completion: nil)
    }
    
    private func cerrarSesion() {
        do {
            try Auth.auth().signOut()
                self.logueado = !self.logueado
            self.realm.objects(UserModel.self).forEach({ user in
                try! self.realm.write {
                    self.realm.delete(user)
                }
            })
            self.performSegue(withIdentifier: "isLogueado", sender: self)
        } catch {
            self.view.servipediaToast("Ocurrio un error al cerrar sesión")
        }
    }
    
    private func eliminarCuenta() {
            if let user = usuarioLogueado,
            let firebase = Auth.auth().currentUser {
            firebase.delete { error in
                if error != nil {
                    self.view.servipediaToast("Ocurrio un error al eliminar el usuario")
                } else {
                    try! self.realm.write {
                        self.realm.delete(user)
                    }
                    self.performSegue(withIdentifier: "isLogueado", sender: self)
                }
            }
            }
            self.logueado = !self.logueado
            self.realm.objects(UserModel.self).forEach({ user in
                try! self.realm.write {
                    self.realm.delete(user)
                }
            })
    }
    
    @objc func serviInstagram() {
        Utils().openInstagram(insta: "https://www.instagram.com/servipedia.oficial")
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
}

extension MainNavController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let nonce = currentNonce,
           let appleIdCredencial = authorization.credential as? ASAuthorizationAppleIDCredential,
           let appleId = appleIdCredencial.identityToken,
           let appleIdString = String(data: appleId, encoding: .utf8) {
            let credencial = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleIdString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credencial) { (result, error) in
                if (error == nil) {
                    let user = UserModel(userId: result?.user.uid, userName: result?.user.displayName, userMail: result?.user.email)
                    
                    try! self.realm.write {
                        self.realm.add(user)
                    }
                    self.usuarioLogueado = user
                    self.logueado = !self.logueado
                    self.performSegue(withIdentifier: "isLogueado", sender: self)
                } else {
                    self.view.servipediaToast("Ocurrio un error al cerrar sesión")
                    self.performSegue(withIdentifier: "isLogueado", sender: self)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.view.servipediaToast("Ocurrio un error al iniciar sesión")
        self.performSegue(withIdentifier: "isLogueado", sender: self)
    }
}
