import Foundation

public class ReseniaModel : Codable {
    var valor: Int?
    var comentario: String?
    var idUser: String?
    var isOwn: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case comentario, valor, idUser
    }
    
    convenience init(valor: Int?, comentario: String?, idUser: String?, isOwn: Bool?) {
        self.init()
        self.valor = valor
        self.comentario = comentario
        self.idUser = idUser
        self.isOwn = isOwn
    }
}
