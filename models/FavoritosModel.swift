//
//  FavoritosModel.swift
//  servipedia
//

import RealmSwift

class FavoritosModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: String?
    @Persisted var lista: List<ServiceItemModel> = List()
    
    convenience init(userId: String? = nil) {
        self.init()
        self.userId = userId
    }
}
