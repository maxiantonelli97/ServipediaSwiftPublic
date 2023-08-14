//
//  Rubro.swift
//  servipedia
//
//

import Foundation

class RubroModel {
    let id: String
    let name: String
    let image: String?
    
    init (id: String, name: String, image: String?) {
        self.name = name
        self.id = id
        self.image = image
    }
}
