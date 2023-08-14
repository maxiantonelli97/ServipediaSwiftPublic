//
//  ServiceItem.swift
//  servipedia
//
//

import Foundation
import RealmSwift

class ServiceItemModel: Object {
    @Persisted var id: String?
    @Persisted var address: String?
    @Persisted var desc: String?
    @Persisted var rubros: List<String> = List()
    @Persisted var instagramLink: String?
    @Persisted var mapLink: String?
    @Persisted var name: String?
    @Persisted var phone: String?
    @Persisted var wsp: String?
    @Persisted var latitud: String?
    @Persisted var longitud: String?
    @Persisted var rating: Double?
    var votes: Array<String> = []
    var favorite: Bool?
    
    convenience init(id: String?, address: String?, desc: String?, rubros: List<String>, instagramLink: String?, mapLink: String?, name: String?, phone: String?, wsp: String?, latitud: String?, longitud: String?, rating: Double?, votes: Array<String>, favorite: Bool?) {
        self.init()
        self.id = id
        self.address = address
        self.desc = desc
        self.rubros = rubros
        self.instagramLink = instagramLink
        self.mapLink = mapLink
        self.name = name
        self.phone = phone
        self.wsp = wsp
        self.latitud = latitud
        self.longitud = longitud
        self.rating = rating ?? 0.0
        self.votes = votes
        self.favorite = favorite
    }
}
