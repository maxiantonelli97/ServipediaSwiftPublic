//
//  AlertDialogViewController.swift
//  servipedia
//
//

import UIKit
import FirebaseCrashlytics

class AlertDialogViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        Crashlytics.crashlytics().log("AlertDialogViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let alert = UIAlertController(title: "Terminos y condiciones", message: "Bienvenido/a a la aplicación móvil Servipedia.\n \nAntes de utilizar esta aplicación, te pedimos que leas detenidamente los siguientes Términos y Condiciones de Uso (en adelante, los \"Términos\").\n\n Estos Términos establecen los derechos y obligaciones legales entre tú (el \"Usuario\") y los propietarios y operadores de la aplicación Servipedia (en adelante, \"nosotros\", \"nos\" o \"nuestro\").\n\n Al acceder o utilizar esta aplicación, aceptas estar legalmente vinculado/a por estos Términos.\n\n Si no estás de acuerdo con alguno de los términos, no utilices la aplicación.\n\n 1- Descripción de la Aplicación\n\n La aplicación Servipedia es una plataforma que permite a los usuarios acceder a una lista de servicios y obtener información de contacto de las personas o instituciones que brindan dichos servicios. Nuestra aplicación actúa como un mero intermediario entre el usuario y los proveedores de servicios.\n No controlamos ni somos responsables de la calidad, cumplimiento o cualquier otro aspecto relacionado con los servicios ofrecidos por terceros a través de nuestra plataforma.\n\n 2- Responsabilidad del Usuario\n\n El Usuario reconoce y acepta que es el único responsable de su uso de la aplicación Servipedia.\n El Usuario comprende que cualquier transacción o comunicación llevada a cabo entre él y los proveedores de servicios es de su exclusiva responsabilidad. El Usuario acepta tomar todas las precauciones necesarias al utilizar la información proporcionada por la aplicación y contratar los servicios ofrecidos por terceros.\n\n 3- Exoneración de Responsabilidad\n\n El Usuario acepta que los propietarios y operadores de la aplicación Servipedia no serán responsables de ningún tipo de daño, pérdida o perjuicio que pueda surgir como resultado de la utilización de los servicios ofrecidos por terceros a través de la aplicación.\n Nosotros nos eximimos expresamente de cualquier responsabilidad relacionada con la calidad, cumplimiento, garantía, o cualquier otro aspecto de los servicios prestados por terceros.\n\n 4- Relación entre el Usuario y los Proveedores de Servicios\n\n El Usuario comprende y acepta que la relación contractual se establece exclusivamente entre él y los proveedores de servicios. Cualquier disputa, reclamo o inconveniente que surja como resultado de la relación entre el Usuario y los proveedores de servicios deberá ser resuelto directamente entre las partes involucradas, sin que nosotros tengamos ninguna responsabilidad o participación en dichas cuestiones.\n\n 5- Modificaciones de la Aplicación y los Términos\n\n Nos reservamos el derecho de modificar, suspender o interrumpir en cualquier momento y sin previo aviso la aplicación Servipedia, así como estos Términos.\n Es responsabilidad del Usuario revisar periódicamente los Términos para estar al tanto de cualquier cambio. El uso continuado de la aplicación después de la modificación de los Términos constituirá la aceptación de dichas modificaciones.\n\n 6- Propiedad Intelectual\n\n Todos los derechos de propiedad intelectual relacionados con la aplicación Servipedia, incluyendo pero no limitándose a marcas registradas, nombres comerciales, logotipos, diseños y contenido, son propiedad exclusiva de los propietarios y operadores de la aplicación.\n Queda prohibida cualquier reproducción, distribución, o utilización no autorizada de dichos elementos sin el consentimiento expreso por escrito de los propietarios.\n\n 7- Ley Aplicable y Jurisdicción\n\n Estos Términos se regirán e interpretarán de acuerdo con las leyes de Argentina sin tener en cuenta conflictos de principios legales. Cualquier disputa, acción legal o procedimiento derivado o relacionado con estos Términos se someterá a la jurisdicción exclusiva de los tribunales competentes de Rosario, Argentina. Si tienes alguna pregunta o inquietud sobre estos Términos y Condiciones, te invitamos a ponerte en contacto con nosotros a través de servipedia.oficial@gmail.com.\n\n Gracias por utilizar la aplicación Servipedia.\n\n Fecha de entrada en vigor: 02-07-2023", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                (self.navigationController as! MainNavController).termsAcept()
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            @unknown default:
                print("error")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
