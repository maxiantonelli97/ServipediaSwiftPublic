//
//  UserModel.swift
//  servipedia
//
//

import RealmSwift

class UserModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: String?
    @Persisted var userName: String?
    @Persisted var userMail: String?
    
    convenience init(userId: String?, userName: String?, userMail: String?) {
        self.init()
        self.userId = userId
        self.userName = userName
        self.userMail = userMail
    }
}
