//
//  TermsModel.swift
//  servipedia
//

import RealmSwift

class TermsModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var termsAcepted: Bool
    
    convenience init(termsAcepted: Bool) {
        self.init()
        self.termsAcepted = termsAcepted
    }
}
